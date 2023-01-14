import QtQuick 2.1
import qb.components 1.0

Tile {
	id: pumpSwitchTile
	property var idArray : []
	property bool dimState: screenStateController.dimmedColors
	

	onClicked: {
		stage.openFullscreen(app.plugScheduleScreenUrl)
	}
	
	Text {
		id: txtTitle
		anchors {
			baseline: parent.top
			baselineOffset: 30
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.bold.name
			pixelSize: qfont.tileTitle
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.waTileTextColor : colors.waTileTextColor
		text: "Slimme stekker\n  Programma"
	}
	
	Text {
		id: txtTitle2
		anchors {
			top: txtTitle.bottom
			topMargin: isNxt ? 10 : 8
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileTitle
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.waTileTextColor : colors.waTileTextColor
		text: app.message
	}
	
	Text {
		id: txtDate
		anchors {
			top: txtTitle2.bottom
			topMargin: isNxt ? 20 : 16
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileTitle2
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.waTileTextColor : colors.waTileTextColor
		text: app.nextSwitchDate
	}
	
	Text {
		id: txtTime
		anchors {
			top: txtDate.bottom
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileTitle2
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.waTileTextColor : colors.waTileTextColor
		text: app.nextSwitchTime
	}
}
