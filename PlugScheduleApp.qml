//2-2022
//by oepi-loepi

import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0;
import BxtClient 1.0
import FileIO 1.0

App {
	id: pumpSwitchApp
	property bool 		debugOutput: true
	property url 		tileUrl : "PlugScheduleTile.qml"
	property 			PlugScheduleTile plugScheduleTile
	property url 		plugScheduleScreenUrl : "PlugScheduleScreen.qml"
	property			PlugScheduleScreen  plugScheduleScreen
	
	property url 		thumbnailIcon: "qrc:/tsc/refresh.png"

	property variant scheduleJson: {}
	property variant switchUuidArray : []
	property variant switchActionArray : []
	property variant switchInterval : []
	property variant currentSwitchInterval : 0
	property string nextSwitchDate
	property string nextSwitchTime
	property string message
	property bool plugsfound
	property int scheduleitemscount : 0	

	property variant newScheduleItem : {
				"pluguuid":"-",
				"starttime":900,
				"endtime":1000,
				"active":0,
				"mo":1,
				"tu":1,
				"we":1,
				"th":1,
				"fr":1,
				"sa":1,
				"su":1
			}

	FileIO {
		id: plugScheduleSettingsFile
		source: "file:///mnt/data/tsc/plugSchedule_userSettings.json"
	}
	
	
	Component.onCompleted: {
		
		try {
			scheduleJson = JSON.parse(plugScheduleSettingsFile.read())
		} catch(e) { // file not found, start with empty JSON
			scheduleJson = JSON.parse('{"scheduleitems":[]}');
		}
		countPlugs();
	}


	function init() {
		registry.registerWidget("tile", tileUrl, this, "plugScheduleTile", {thumbLabel: qsTr("plugSchedule"), thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, baseTileSolarWeight: 10, thumbIconVAlignment: "center"})
		registry.registerWidget("screen", plugScheduleScreenUrl, this, "plugScheduleScreen")
	}
	


	function saveSchedule() {
	
  		plugScheduleSettingsFile.write(JSON.stringify(scheduleJson));
		scheduleitemscount = scheduleJson["scheduleitems"].length;

	}	


	function decodeDay(daynr) {
		switch (daynr) {
			case 0: return "su";
			case 1: return "mo";
			case 2: return "tu";
			case 3: return "we";
			case 4: return "th";
			case 5: return "fr";
			case 6: return "sa";
			default: break;
		}
		return "error_day";
	}
	
	function determineFirstSwitchmoment() {

			// calculate next switch times for each active row in the JSON (can be multiple switches at the same time)
		
		switchActionArray.length = 0;
		switchUuidArray.length = 0;
		switchInterval.length = 0;

		for (var i=0;i<scheduleJson["scheduleitems"].length;i++) {			
			if (scheduleJson["scheduleitems"][i]["active"] == 1) {
				calculateSwitchTime(i);
			}
		}

		console.log("****** plugScheduleSwithTimes in seconds from now");
		console.log(switchActionArray);
		console.log(switchUuidArray);
		console.log(switchInterval);

			// find lowest switch time in array

		currentSwitchInterval  = 9999999999
		for (var i=0;i<switchInterval.length;i++) {
			if (switchInterval[i] < currentSwitchInterval ) {
				currentSwitchInterval = switchInterval[i];
			}
		}

		if (currentSwitchInterval == 9999999999) {
			// no switch time detected, do nothing, wait for manual screen update
			plugTimer.stop();
			console.log("***** plugTimer stopped");
			if (!plugsfound) {
				nextSwitchDate = "Geen slimme stekkers"; 
				nextSwitchTime = "gekoppeld aan Toon";
				message = "Probleem:"
			} else { 
				nextSwitchDate = "--/--/--";
				nextSwitchTime = "--:--";
				message = "Volgende aktie op:";
			}
		} else {
			plugTimer.interval = currentSwitchInterval * 1000;
			plugTimer.start();
			var nextSwitchEvent = new Date();
			nextSwitchEvent.setSeconds(nextSwitchEvent.getSeconds() + currentSwitchInterval);
 			var minutes = nextSwitchEvent.getMinutes();
			if (minutes < 10) minutes = "0" + minutes;
			var hours = nextSwitchEvent.getHours();
			if (hours < 10) hours = "0" + hours;
			var month = nextSwitchEvent.getMonth() + 1;
			if (month < 10) month = "0" + month;
			var hours = nextSwitchEvent.getHours();
			if (hours < 10) hours = "0" + hours;
			nextSwitchDate = nextSwitchEvent.getDate() + "/" + month;
			nextSwitchTime = hours + ":" + minutes;
			message = "Volgende aktie op:";

			console.log("***** plugTimer started (ms):" + (currentSwitchInterval * 1000) + " at " + nextSwitchDate + " " + nextSwitchTime);
		}
	}

	function actionPlugTimer() {

		console.log("***** plug fired from " + currentSwitchInterval );
			// execute action for the plug(s) at this time

		for (var i=0;i<switchInterval.length;i++) {
			if (switchInterval[i] == currentSwitchInterval ) {

				var msg = bxtFactory.newBxtMessage(BxtMessage.ACTION_INVOKE, switchUuidArray[i], "SwitchPower", "SetTarget");
				msg.addArgument("NewTargetValue", switchActionArray[i]);
				bxtClient.sendMsg(msg);
				bxtClient.sendMsg(msg); // do it twice because sometimes the plug does not respond

			}
		}
		determineFirstSwitchmoment();
	}



	function calculateSwitchTime(index){

		var now = new Date();
		var nowDayOfWeek = now.getDay(); // 0 = sunday, 6 = saturday
		var nowSeconds = now.getSeconds() + (now.getMinutes() * 60)  + (now.getHours() * 3600);
		var jsonTime = 0;
		var jsonHours = 0;
		var jsonMinutes = 0;
		var switchOnInterval = 0;
		var switchOffInterval = 0;
		var startday = 0;

		 // calculate SwitchOn interval first

		jsonTime = scheduleJson["scheduleitems"][index]["starttime"] / 100;
		jsonHours = Math.floor(jsonTime);
		jsonMinutes = (-jsonHours * 100) + scheduleJson["scheduleitems"][index]["starttime"];
		switchOnInterval = -nowSeconds + (jsonMinutes * 60) + (jsonHours  * 3600);

			// store plug start moments

		if (switchOnInterval > 0) {
			startday = nowDayOfWeek;
		} else {
			startday = nowDayOfWeek + 1;
			if (startday == 7) startday = 0;
			switchOnInterval = switchOnInterval + 86400;
		}

		for (var j=0;j<7;j++) {
			if (scheduleJson["scheduleitems"][index][decodeDay((startday + j) % 7)] == 1) {
				switchActionArray.push("1");
				switchUuidArray.push(scheduleJson["scheduleitems"][index]["pluguuid"]);
				switchInterval.push(switchOnInterval + (j * 86400));
				break;
			}
		}

			// store plug stop moments

		jsonTime = scheduleJson["scheduleitems"][index]["endtime"] / 100;
		jsonHours = Math.floor(jsonTime);
		jsonMinutes = (-jsonHours * 100) + scheduleJson["scheduleitems"][index]["endtime"];
		switchOffInterval = -nowSeconds + (jsonMinutes * 60) + (jsonHours  * 3600);

		if (switchOffInterval > 0) {
			startday = nowDayOfWeek;
		} else {
			startday = nowDayOfWeek + 1;
			if (startday == 7) startday = 0;
			switchOffInterval = switchOffInterval + 86400;
		}

		for (var j=0;j<7;j++) {
			if (scheduleJson["scheduleitems"][index][decodeDay((startday + j) % 7)] == 1) {
				switchActionArray.push("0");
				switchUuidArray.push(scheduleJson["scheduleitems"][index]["pluguuid"]);
				switchInterval.push(switchOffInterval + (j * 86400));
				break;
			}
		}
	}

	function countPlugs(){
	
		plugsfound=false
		var doc = new XMLHttpRequest();
		doc.onreadystatechange = function() {
			if (doc.readyState == XMLHttpRequest.DONE) {
				var devicesfile = doc.responseText;
				var devices = devicesfile.split('<device>')
				for(var x0 = 0;x0 < devices.length;x0++){
					if((devices[x0].toUpperCase().indexOf('PUMP')>0 & devices[x0].toUpperCase().indexOf('SWITCH')>0) || devices[x0].indexOf('FGWPF102')>0 || devices[x0].indexOf('ZMNHYD1')>0 ||devices[x0].indexOf('FGWP011')>0 ||devices[x0].indexOf('NAS_WR01Z')>0 ||devices[x0].indexOf('NAS_WR01ZE')>0 ||devices[x0].indexOf('NAS_WR02ZE')>0 ||devices[x0].indexOf('EMPOWER')>0 ||devices[x0].indexOf('EM6550_v1')>0) {
						plugsfound=true;
						determineFirstSwitchmoment();
					}
				}
			}
		}
		doc.open("GET", "file:////qmf/config/config_happ_smartplug.xml", true);
		doc.setRequestHeader("Content-Encoding", "UTF-8");
		doc.send();
	}

	
	Timer {
		id: plugTimer
		interval: 600000
		triggeredOnStart: false
		running: false
		repeat: false
		onTriggered: actionPlugTimer()
	}
}