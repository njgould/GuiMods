////// detail page for setting inverter mode
////// and displaying inverter details
////// pushed from Flow overview

import QtQuick 1.1
import "utils.js" as Utils
import com.victron.velib 1.0

MbPage {
	id: root
 
    title: "Inverter Detail"
    
    property string systemPrefix: "com.victronenergy.system"

	property int fontPixelSize: 18
	property color buttonColor: "#979797"
    property color pressedColor: "#d3d3d3"
    property color backgroundColor: "#b3b3b3"

    property int inverterMode: inverterModeItem.valid ? inverterModeItem.value : 0
    property bool editable: inverterService != "" && inverterModeItem.valid
    property int buttonHeight: 40
    property int tableColumnWidth: 60
    property int rowTitleWidth: 130
    property int dataColumns: 3
    property int totalDataWidth: tableColumnWidth * dataColumns
    property int legColumnWidth: phaseCount <= 1 ? totalDataWidth : totalDataWidth / phaseCount

    property int numberOfMultis: 0
    property int numberOfInverters: 0
    property string inverterService: ""
    property bool isInverter: numberOfMultis === 0 && numberOfInverters === 1

    Component.onCompleted: { discoverServices(); highlightMode () }

    VBusItem
    {
        id: inverterModeItem
        bind: Utils.path(inverterService, "/Mode")
        onValidChanged: highlightMode ()
        onValueChanged: highlightMode ()
    }
    property VBusItem systemState: VBusItem { bind: Utils.path(systemPrefix, "/SystemState/State") }
    SystemState
    {
        id: vebusState
        bind: systemState.valid?Utils.path(systemPrefix, "/SystemState/State"):Utils.path(inverterService, "/State")
    }
    VBusItem { id: pInL1; bind: Utils.path(inverterService, "/Ac/ActiveIn/L1/P") }
    VBusItem { id: pInL2; bind: Utils.path(inverterService, "/Ac/ActiveIn/L2/P") }
    VBusItem { id: pInL3; bind: Utils.path(inverterService, "/Ac/ActiveIn/L2/P") }
    VBusItem { id: vInL1; bind: Utils.path(inverterService, "/Ac/ActiveIn/L1/V") }
    VBusItem { id: vInL2; bind: Utils.path(inverterService, "/Ac/ActiveIn/L2/V") }
    VBusItem { id: vInL3; bind: Utils.path(inverterService, "/Ac/ActiveIn/L3/V") }
    VBusItem { id: iInL1; bind: Utils.path(inverterService, "/Ac/ActiveIn/L1/I") }
    VBusItem { id: iInL2; bind: Utils.path(inverterService, "/Ac/ActiveIn/L2/I") }
    VBusItem { id: iInL3; bind: Utils.path(inverterService, "/Ac/ActiveIn/L3/I") }
    VBusItem { id: pOutL1; bind: Utils.path(inverterService, "/Ac/Out/L1/P") }
    VBusItem { id: pOutL2; bind: Utils.path(inverterService, "/Ac/Out/L2/P") }
    VBusItem { id: pOutL3; bind: Utils.path(inverterService, "/Ac/Out/L3/P") }
    VBusItem { id: vOutL1; bind: Utils.path(inverterService, "/Ac/Out/L1/V") }
    VBusItem { id: vOutL2; bind: Utils.path(inverterService, "/Ac/Out/L2/V") }
    VBusItem { id: vOutL3; bind: Utils.path(inverterService, "/Ac/Out/L3/V") }
    VBusItem { id: iOutL1; bind: Utils.path(inverterService, "/Ac/Out/L1/I") }
    VBusItem { id: iOutL2; bind: Utils.path(inverterService, "/Ac/Out/L2/I") }
    VBusItem { id: iOutL3; bind: Utils.path(inverterService, "/Ac/Out/L3/I") }
    VBusItem { id: fInL1; bind: Utils.path(inverterService, "/Ac/ActiveIn/L1/F") }
    VBusItem { id: fOutL1; bind: Utils.path(inverterService, "/Ac/Out/L1/F") }
    VBusItem { id: splitPhaseL2Passthru; bind: Utils.path(inverterService, "/Ac/State/SplitPhaseL2Passthru") }
    VBusItem { id: phaseCountItem; bind: Utils.path(inverterService, "/Ac/NumberOfPhases") }

    property bool l1AndL2OutShorted: splitPhaseL2Passthru.valid && splitPhaseL2Passthru.value === 0
    property int phaseCount: phaseCountItem.valid ? phaseCountItem.value : 0

    // background
    Rectangle
    {
        anchors
        {
            fill: parent
        }
        color: root.backgroundColor
    }

    Row
    {
        spacing: 5
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        Column 
        {
            spacing: 2
            Row
            {
                PowerGaugeMulti
                {
                    id: gauge
                    width: rowTitleWidth + totalDataWidth
                    height: 15
                    inverterService: root.inverterService
                }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: "Total Power" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: totalDataWidth; horizontalAlignment: Text.AlignHCenter
                        text:
                        {
                            var total = 0
                            var totalValid = false
                            if (pOutL1.valid && pInL1.valid)
                            {
                                total += pOutL1.value - pInL1.value
                                totalValid = true
                            }
                            if (pOutL2.vaild && pInL2.valid)
                            {
                                total += pOutL2.value - pInL2.value
                                totalValid = true
                            }
                            if (pOutL3.vaild && pInL3.valid)
                            {
                                total += pOutL3.value - pInL3.value
                                totalValid = true
                            }
                            if (totalValid)
                                return total.toFixed (0) + " W"
                            else
                                return "--"
                        }                        
                    }
                visible: phaseCount >= 2
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: "State" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: totalDataWidth; horizontalAlignment: Text.AlignHCenter
                        text: vebusState.text }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: "" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L1" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L2" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L3"; visible: phaseCount >= 3 }
                visible: phaseCount >= 2
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: "Power" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValueDiff (pOutL1, pInL1, " W") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: l1AndL2OutShorted ? "< < <" : formatValueDiff (pOutL2, pInL2, " W"); visible: phaseCount >= 2 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValueDiff (pOutL3, pInL3, " W"); visible: phaseCount >= 3 }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: "Input Voltage" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (vInL1, " V") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (vInL2, " V"); visible: phaseCount >= 2 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (vInL3, " V"); visible: phaseCount >= 3 }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: "Output Voltage" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (vOutL1, " V") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (vOutL2, " V"); visible: phaseCount >= 2 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (vOutL3, " V"); visible: phaseCount >= 3 }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: "Input Current" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (iInL1, " A") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (iInL2, " A"); visible: phaseCount >= 2 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (iInL3, " A"); visible: phaseCount >= 3 }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: "Output Current" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (iOutL1, " A") }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: l1AndL2OutShorted ? "< < <" :formatValue (iOutL2, " A"); visible: phaseCount >= 2 }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: legColumnWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (iOutL3, " A"); visible: phaseCount >= 3 }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: "Input Frequency" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: totalDataWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (fInL1, " Hz") }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth; horizontalAlignment: Text.AlignRight
                        text: "Output Frequency" }
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: totalDataWidth; horizontalAlignment: Text.AlignHCenter
                        text: formatValue (fOutL1, " Hz") }
            }
            Row
            {
                Text { font.pixelSize: 12; font.bold: true; color: "black"
                        width: rowTitleWidth + totalDataWidth; horizontalAlignment: Text.AlignHCenter
                        text: "L2 Output values included in L1"
                        visible: l1AndL2OutShorted }
            }
        }
        Column
        {
            width: 80
            spacing: 4

            Button
            {
                id: onButton
                baseColor: inverterMode === 3 ? "green" : "#e6ffe6"
                pressedColor: root.pressedColor
                height: root.buttonHeight
                width: parent.width - 6
                visible: !isInverter           
                onClicked: changeMode(3)
                content: TileText
                {
                    text: qsTr("On"); font.bold: true;
                    color: inverterMode === 3 ? "white" : "black"
                }
            }
            Button
            {
                id: offButton
                baseColor: inverterMode === 4 ? "black" : "#e6e6e6"
                pressedColor: root.pressedColor
                height: root.buttonHeight
                width: parent.width - 6
                onClicked: changeMode(4)
                content: TileText
                {
                    text: qsTr("Off"); font.bold: true;
                    color: inverterMode === 4 ? "white" : "black"
                }
            }
            Button
            {
                id: invertOnlyButton
                baseColor: inverterMode === 2 ? "blue" : "#ccccff"
                pressedColor: root.pressedColor
                height: root.buttonHeight
                width: parent.width - 6
                onClicked: changeMode(2)
                content: TileText
                {
                    text: isInverter ? qsTr("On") : qsTr("Inverter\nOnly"); font.bold: true;
                    color: inverterMode === 2 ? "white" : "black"
                }
            }
            Button 
            {
                id: chargeOnlyButton
                baseColor: inverterMode === 1 ? "orange" : "#ffedcc"
                pressedColor: root.pressedColor
                height: root.buttonHeight
                width: parent.width - 6
                visible: !isInverter           
                onClicked: changeMode(1)
                content: TileText
                {
                    text: qsTr("Charger\nOnly"); font.bold: true;
                    color: inverterMode === 1 ? "white" : "black"
                }
            }
            Button 
            {
                id: ecoButton
                baseColor: inverterMode === 5 ? "orange" : "#ffedcc"
                pressedColor: root.pressedColor
                height: root.buttonHeight
                width: parent.width - 6
                visible: isInverter         
                onClicked: changeMode(5)
                content: TileText
                {
                    text: qsTr("Eco"); font.bold: true;
                    color: inverterMode === 5 ? "white" : "black"
                }
            }
        }
    }

	function changeMode(newMode)
	{
        if (editable)
        {
            inverterModeItem.setValue(newMode)
            pageStack.pop() // return to flow screen after changing inverter mode
        }
	}

	function cancel()
	{
		pageStack.pop()
	}
 
    function highlightMode ()
    {
        if (editable)
            inverterMode = inverterModeItem.value
        else
            inverterMode = 0
    }


    // When new service is found check if is a tank sensor
    Connections
    {
        target: DBusServices
        onDbusServiceFound: addService(service)
    }

    function addService(service)
    {
         switch (service.type)
        {
        case DBusService.DBUS_SERVICE_MULTI:
            numberOfMultis++
            if (numberOfMultis === 1)
                inverterService = service.name;
            break;;
        case DBusService.DBUS_SERVICE_INVERTER:
            numberOfInverters++
            if (numberOfInverters === 1 && inverterService == "")
                inverterService = service.name;
            break;;
        }
    }

    // Detect available services of interest
    function discoverServices()
    {
        numberOfMultis = 0
        numberOfInverters = 0
        inverterService = ""
        for (var i = 0; i < DBusServices.count; i++)
        {
            addService(DBusServices.at(i))
        }
    }

    function formatValue (item, unit)
    {
        var value
        if (item.valid)
        {
            value = item.value
            if (value < 100)
                return value.toFixed (1) + unit
            else
                return value.toFixed (0) + unit
        }
        else
            return "--"
    }

    function formatValueDiff (item1, item2, unit)
    {
        var value
        if (item1.valid && item2.valid)
        {
            value = item2.value - item2.value
            if (value < 100)
                return value.toFixed (1) + unit
            else
                return value.toFixed (0) + unit
        }
        else
            return "--"
    }
}
