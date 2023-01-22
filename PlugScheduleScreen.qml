import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0

Screen {
	id: pumpSwitchConfigScreen
	screenTitle: 		"Schakelmomenten slimme stekkers"
	property variant    	plugNamesArray : []
	property variant    	plugUuidArray : []
	property bool debugOutput : true
	property int startTime
	
	onShown: {
		getPlugNames();
		addCustomTopRightButton("Toepassen");
	}
	
	onCustomButtonClicked: {
		app.determineFirstSwitchmoment();
		hide();
	}
	
	function getPlugNames(){
		model.clear()	
		app.plugsfound=false
		plugNamesArray.length = 0; //empty arrays (refresh plug list)
		plugUuidArray.length = 0;
		var doc = new XMLHttpRequest();
		doc.onreadystatechange = function() {
				if (doc.readyState == XMLHttpRequest.DONE) {
					var devicesfile = doc.responseText;
					var devices = devicesfile.split('<device>')
					for(var x0 = 0;x0 < devices.length;x0++){
						if((devices[x0].toUpperCase().indexOf('PUMP')>0 & devices[x0].toUpperCase().indexOf('SWITCH')>0) || devices[x0].indexOf('FGWPF102')>0 || devices[x0].indexOf('ZMNHYD1')>0 ||devices[x0].indexOf('FGWP011')>0 ||devices[x0].indexOf('NAS_WR01Z')>0 ||devices[x0].indexOf('NAS_WR01ZE')>0 ||devices[x0].indexOf('NAS_WR02ZE')>0 ||devices[x0].indexOf('EMPOWER')>0 ||devices[x0].indexOf('EM6550_v1')>0)
						{
							var n20 = devices[x0].indexOf('<uuid>') + 6
							var n21 = devices[x0].indexOf('</uuid>',n20)
							var devicesuuid = devices[x0].substring(n20, n21)
							
							var n40 = devices[x0].indexOf('<name>') + 6
							var n41 = devices[x0].indexOf('</name>',n40)
							var devicesname = devices[x0].substring(n40, n41)

							plugNamesArray.push(devicesname.trim());
							plugUuidArray.push(devicesuuid.trim());
							
							if (devicesuuid.length>5){// plugs found
								app.plugsfound=true;
							}
						}	
					}

					var doc2 = new XMLHttpRequest();
					doc2.onreadystatechange = function() {
						if (doc2.readyState == XMLHttpRequest.DONE) {
							var devicesfile2 = doc2.responseText;
							var devices2 = devicesfile2.split('<device>')
							for (var x0 = 0;x0 < devices2.length;x0++){
								if (devices2[x0].toUpperCase().indexOf('SWITCHPOWER')>0) {
									var n20 = devices2[x0].indexOf('<uuid>') + 6
									var n21 = devices2[x0].indexOf('</uuid>',n20)
									var devicesuuid2 = devices2[x0].substring(n20, n21)
							
									var n40 = devices2[x0].indexOf('<name>') + 6
									var n41 = devices2[x0].indexOf('</name>',n40)
									var devicesname2 = devices2[x0].substring(n40, n41)

									plugNamesArray.push(devicesname2.trim());
									plugUuidArray.push(devicesuuid2.trim());
							
									if (devicesuuid2.length>5){
										app.plugsfound=true;
									}
								}	
							}
							if (!app.plugsfound) {
								app.nextSwitchDate = "Geen slimme stekkers"; 
								app.currentSwitchName= "gekoppeld aan Toon";
								app.currentSwitchAction = "";
								app.nextSwitchTime = "";
								app.message = "Probleem:"
								hide();
							} else { 
								loadScreen();
							}
						}
					}
					doc2.open("GET", "file:////qmf/config/config_hdrv_hue.xml", true);
					doc2.setRequestHeader("Content-Encoding", "UTF-8");
					doc2.send();
				}
		}
		doc.open("GET", "file:////qmf/config/config_happ_smartplug.xml", true);
		doc.setRequestHeader("Content-Encoding", "UTF-8");
		doc.send();
	}
	
	function loadScreen(){
		listview1.model.clear();	
		listview1.model.append(app.scheduleJson["scheduleitems"])
	}

	function getName(pluguuid){
		if (plugUuidArray.length > 0) {
			for (var i=0; i<plugUuidArray.length; i++) {
				if (plugUuidArray[i]== pluguuid) {
					return plugNamesArray[i];
					break;
				}
			}
		}
		return "Onbekend"
	}

	
	Rectangle{
		id: listviewContainer1
		width: parent.width
		height: isNxt ? 450 : 360
		radius: isNxt ? 5 : 4
		anchors {
			top: parent.top
			topMargin: isNxt ? 60: 48
			leftMargin: isNxt ? 12 : 10
			left: parent.left
		}
		Text {
			id: heading1
			width: isNxt ? 325:260
			text: "Slimme stekker"
			font.family: qfont.bold.name
			font.pixelSize: isNxt ? 35 : 28
			anchors {
				top: parent.top
				topMargin: isNxt ? -50 : -40
				leftMargin: isNxt ? 12 : 10
				left: parent.left
			}
		}
		Text {
			id: heading2
			text: "Tijd"
			width: isNxt ? 100:80
			font.pixelSize: isNxt ? 35:28
			font.family: qfont.bold.name
			anchors {
				top: heading1.top
				leftMargin: isNxt ? 12 : 9
				left: heading1.right
			}
		}
		Text {
			id: heading3
			text: "Wat"
			width: isNxt ? 100:80
			font.family: qfont.bold.name
			font.pixelSize: isNxt ? 35:28
			anchors {
				top: heading1.top
				leftMargin: isNxt ? 12 : 9
				left: heading2.right
			}
		}
		Text {
			id: heading4
			text: "M"
			width: isNxt ? 30 : 24
			font.family: qfont.bold.name
			font.pixelSize: isNxt ? 35:28
			anchors {
				top: heading1.top
				leftMargin: isNxt ? 8 : 6
				left: heading3.right
			}
		}
		Text {
			id: heading5
			text: "D"
			width: isNxt ? 30 : 24
			font.family: qfont.bold.name
			font.pixelSize: isNxt ? 35:28
			anchors {
				top: heading1.top
				leftMargin: isNxt ? 16 : 12
				left: heading4.right
			}
		}
		Text {
			id: heading6
			text: "W"
			width: isNxt ? 30 : 24
			font.family: qfont.bold.name
			font.pixelSize: isNxt ? 35:28
			anchors {
				top: heading1.top
				leftMargin: isNxt ? 8 : 6
				left: heading5.right
			}
		}
		Text {
			id: heading7
			text: "D"
			width: isNxt ? 30 : 24
			font.family: qfont.bold.name
			font.pixelSize: isNxt ? 35:28
			anchors {
				top: heading1.top
				leftMargin: isNxt ? 16 : 12
				left: heading6.right
			}
		}
		Text {
			id: heading8
			text: "V"
			width: isNxt ? 30 : 24
			font.family: qfont.bold.name
			font.pixelSize: isNxt ? 35:28
			anchors {
				top: heading1.top
				leftMargin: isNxt ? 12 : 9
				left: heading7.right
			}
		}
		Text {
			id: heading9
			text: "Z"
			width: isNxt ? 30 : 24
			font.family: qfont.bold.name
			font.pixelSize: isNxt ? 35:28
			anchors {
				top: heading1.top
				leftMargin: isNxt ? 12 : 9
				left: heading8.right
			}
		}
		Text {
			id: heading10
			text: "Z"
			width: isNxt ? 30 : 24
			font.family: qfont.bold.name
			font.pixelSize: isNxt ? 35:28
			anchors {
				top: heading1.top
				leftMargin: isNxt ? 12 : 9
				left: heading9.right
			}
		}
	
		StandardButton {
			id: addNewRowToJson
			text: "Nieuwe regel"
			width: 150
			anchors.right: parent.right
			anchors.rightMargin: 20
			anchors.bottom: parent.bottom
			anchors.bottomMargin: 5
			visible: (app.scheduleitemscount < 8)
			onClicked: {
				if (plugUuidArray[0]) app.newScheduleItem["pluguuid"] = plugUuidArray[0];
				app.scheduleJson["scheduleitems"].push(JSON.parse(JSON.stringify(app.newScheduleItem)));
				app.saveSchedule();
				loadScreen();
			}
		}

		Component {
			id: plugDelegate
			Item {

				function saveStartTime(text) {
					if (text) {
						app.scheduleJson["scheduleitems"][index]["starttime"] = parseInt(text);
						app.saveSchedule();
						loadScreen();
					}
				}

				function formatTime(numtime) {
					var strTime = "0000"+ numtime;
					strTime = strTime.slice(-4);
					return strTime.substring(0,2) + ":" + strTime.slice(-2)
				}

				function validateTime(text, isFinalString) {
					var strTime = "0000"+ text;
					if (parseInt(text.substring(0,2)) > 23) return {title: "Ongeldig aantal uren", content: "Voer een getal in kleiner dan 24"};
					if (parseInt(text.substring(2,4)) > 59) return {title: "Ongeldig aantal minuten", content: "Voer een getal in kleiner dan 60"};
					return null;
				}


				width: isNxt ? 125 : 120
				height: isNxt ? 50 : 40

				Text {
					id: namePlug
					text: getName(pluguuid)
					width: isNxt ? 325:260
					font.pixelSize: isNxt ? 35:28
					font.family: (active == 1) ? qfont.bold.name : qfont.regular.name

					MouseArea {
						anchors.fill: parent
						onClicked: { //rotate plugs
							var plugFound = false;
							if (plugUuidArray.length < 2) {
								// message: no other plugs exist
							} else {	// show next smartPlug, or the first if this one was the last
								for (var i=0;i<plugUuidArray.length; i++) {
									if (pluguuid == plugUuidArray[i]) {
										plugFound = true;
										if (i == plugUuidArray.length -1) { 
											app.scheduleJson["scheduleitems"][index]["pluguuid"] = plugUuidArray[0];
										} else {
											app.scheduleJson["scheduleitems"][index]["pluguuid"] = plugUuidArray[i+1];
										}
									}
									if (plugFound) i = plugUuidArray.length;
								}
							}				
							if (!plugFound) app.scheduleJson["scheduleitems"][index]["pluguuid"] = plugUuidArray[0];
							app.saveSchedule();
							loadScreen();
						}
					}
				}

				Text {
					id: starttimelabel
					text: formatTime(starttime)
					width: isNxt ? 100:80
					font.pixelSize: isNxt ? 35:28
					font.family: (active == 1) ? qfont.bold.name : qfont.regular.name
					anchors {
						leftMargin: isNxt ? 12 : 9
						left: namePlug.right
					}

					MouseArea {
						anchors.fill: parent
						onClicked: {
							qnumKeyboard.open("Voer starttijd in (HHMM)", starttimelabel.text.substring(0,2) + starttimelabel.text.substring(3,5), "", 1 , saveStartTime, validateTime);
						}
					}
				}
				Text {
					id: actionlabel
					text: action
					width: isNxt ? 100:80
					font.family: (active == 1) ? qfont.bold.name : qfont.regular.name
					font.pixelSize: isNxt ? 35:28
					anchors {
						leftMargin: isNxt ? 12 : 9
						left: starttimelabel.right
					}

					MouseArea {
						anchors.fill: parent
						onClicked: {
							if (action == "Aan") {
								app.scheduleJson["scheduleitems"][index]["action"] = "Uit"
							} else {
								app.scheduleJson["scheduleitems"][index]["action"] = "Aan"
							}
							app.saveSchedule();
							loadScreen();
						}
					}
				}
				Text {
					id: mondaylabel
					text: (mo == 1) ? "V" : "-"
					width: isNxt ? 30 : 24
					font.family: qfont.regular.name
					font.pixelSize: isNxt ? 35:28
					anchors {
						leftMargin: isNxt ? 12 : 9
						left: actionlabel.right
					}

					MouseArea {
						anchors.fill: parent
						onClicked: {
							app.scheduleJson["scheduleitems"][index]["mo"] = 1 - mo;
							app.saveSchedule();
							loadScreen();
						}
					}
				}
				Text {
					id: tuesdaylabel
					text: (tu == 1) ? "V" : "-"
					width: isNxt ? 30 : 24
					font.family: qfont.regular.name
					font.pixelSize: isNxt ? 35:28
					anchors {
						leftMargin: isNxt ? 12 : 9
						left: mondaylabel.right
					}

					MouseArea {
						anchors.fill: parent
						onClicked: {
							app.scheduleJson["scheduleitems"][index]["tu"] = 1 - tu;
							app.saveSchedule();
							loadScreen();
						}
					}
				}
				Text {
					id: wednesdaylabel
					text: (we == 1) ? "V" : "-"
					width: isNxt ? 30 : 24
					font.family: qfont.regular.name
					font.pixelSize: isNxt ? 35:28
					anchors {
						leftMargin: isNxt ? 12 : 9
						left: tuesdaylabel.right
					}

					MouseArea {
						anchors.fill: parent
						onClicked: {
							app.scheduleJson["scheduleitems"][index]["we"] = 1 - we;
							app.saveSchedule();
							loadScreen();
						}
					}
				}
				Text {
					id: thursdaylabel
					text: (th == 1) ? "V" : "-"
					width: isNxt ? 30 : 24
					font.family: qfont.regular.name
					font.pixelSize: isNxt ? 35:28
					anchors {
						leftMargin: isNxt ? 12 : 9
						left: wednesdaylabel.right
					}

					MouseArea {
						anchors.fill: parent
						onClicked: {
							app.scheduleJson["scheduleitems"][index]["th"] = 1 - th;
							app.saveSchedule();
							loadScreen();
						}
					}
				}
				Text {
					id: fridaylabel
					text: (fr == 1) ? "V" : "-"
					width: isNxt ? 30 : 24
					font.family: qfont.regular.name
					font.pixelSize: isNxt ? 35:28
					anchors {
						leftMargin: isNxt ? 12 : 9
						left: thursdaylabel.right
					}

					MouseArea {
						anchors.fill: parent
						onClicked: {
							app.scheduleJson["scheduleitems"][index]["fr"] = 1 - fr;
							app.saveSchedule();
							loadScreen();
						}
					}
				}
				Text {
					id: saturdaylabel
					text: (sa == 1) ? "V" : "-"
					width: isNxt ? 30 : 24
					font.family: qfont.regular.name
					font.pixelSize: isNxt ? 35:28
					anchors {
						leftMargin: isNxt ? 12 : 9
						left: fridaylabel.right
					}

					MouseArea {
						anchors.fill: parent
						onClicked: {
							app.scheduleJson["scheduleitems"][index]["sa"] = 1 - sa;
							app.saveSchedule();
							loadScreen();
						}
					}
				}
				Text {
					id: sundaylabel
					text: (su == 1) ? "V" : "-"
					width: isNxt ? 30 : 24
					font.family: qfont.regular.name
					font.pixelSize: isNxt ? 35:28
					anchors {
						leftMargin: isNxt ? 12 : 9
						left: saturdaylabel.right
					}

					MouseArea {
						anchors.fill: parent
						onClicked: {
							app.scheduleJson["scheduleitems"][index]["su"] = 1 - su;
							app.saveSchedule();
							loadScreen();
						}
					}
				}
				OnOffToggle {
					id: activeToggleLabel
					isSwitchedOn: (active == 1)
					anchors {
						left: sundaylabel.right
						leftMargin: isNxt ? 35 : 28
					}
					leftIsSwitchedOn: false
					onSelectedChangedByUser: {
						app.scheduleJson["scheduleitems"][index]["active"] = 1 - active
						app.saveSchedule();
						loadScreen();
					}
				}

				IconButton {
					id: deleteScheduleButton
					width: isNxt ? 35 : 35
					height: isNxt ? 35 : 35
					iconSource: "qrc:/tsc/icon_delete.png"
					anchors {
						left: activeToggleLabel.right
						leftMargin: isNxt ? 10 : 8
					}
					onClicked: {
						app.scheduleJson["scheduleitems"].splice(index,1);
						app.saveSchedule();
						loadScreen();
					}
				}
			}
		}

		ListModel {
				id: model
		}
		ListView {
			id: listview1
			anchors {
				top: parent.top
				topMargin:isNxt ? 20 : 16
				leftMargin: isNxt ? 12 : 9
				left: parent.left
			}
			width: parent.width
			height: isNxt ? (parent.height-50) : (parent.height-40)
			model: model
			delegate: plugDelegate
			focus: true
		}
	}

	Timer {
		id: intervalTimer   //time to refresh screen
		interval: 100
		repeat: false
		running: false
		triggeredOnStart: false
		onTriggered: {
			getPlugNames();
        	}
	}	
}