function _SetControlEnabled(control = "", enabled = "")
{
    var event = LIEvent.createEventForEventTypeControlValueStringSuffixValue("setControlEnabled", control, enabled, "", "");
    eventArray.push(event);
};

function _SetControlVisibility(control = "", visible = "")
{
    var event = LIEvent.createEventForEventTypeControlValueStringSuffixValue("setControlVisibility", control, visible, "", "");
    eventArray.push(event);
};

//function _SetControlVisibility(control = "", visible = "")
//{
//    setControlVisibilitySwift(control, visible);
//};

function _GetControlVisibility(control = "")
{
    return getControlVisibilitySwift(control);
};

function _SetTextColor(control = "", color = "")
{
    var event = LIEvent.createEventForEventTypeControlValueStringSuffixValue("setTextColor", control, color, "", "");
    eventArray.push(event);
};

function _GetValidationChanges()
{
//    return validationChanges;
    const subList = [];
    for (var rule in validationRules) {
        if (!Object.hasOwn(validationRules, rule))
            continue;
        var rul = validationRules[rule];
        if (rul.oldState !== rul.newState) {
            subList.push(rul);
        }
    }
    return subList;
}

function _GetValidationRules(type = "all")
{
    const subList = [];
    var searchType = "";
    switch(type.toLowerCase()) {
        case "all":
//            return validationRules;
            searchType = "all"
            break;
        case "passed":
            searchType = "Passed";
            break;
        case "notpassed":
            searchType = "NotPassed";
            break;
        case "notnow":
            searchType = "NotNow";
            break;
        case "error":
            searchType = "ExecutionError";
            break;
        case "isfinal":
            searchType = "IsFinal";
            break;
        default:
            return validationRules;
    }
    for (var rule in validationRules) {
        if (!Object.hasOwn(validationRules, rule))
            continue;
        var rul = validationRules[rule];
        var result = rul.result.toLowerCase();
        var search = searchType.toLowerCase();
        if (search === "all") {
            if (rul.isVisible) {
                subList.push(rul);
            }
        }
        else {
            if (result === search) {
                subList.push(rul);
            }
            else {
                if (
                    (search === "notpassed") &&
                    ((result === "isfinal") ||
                     (result === "notnowisfinal") ||
                     (result === "executionerror"))
                    ) {
                        subList.push(rul);
                    }
                else {
                    if (result.indexOf(search) !== -1) {
                        if ((search === "passed") && (result === "notpassed")) {}
                        else {
                            subList.push(rul);
                        }
                    }
                    else {
                        if ((search === "isfinal") && (rul.isFinal === true)) {
                            subList.push(rul)
                        }
                    }
                }
            }
        }
    }

    return subList;
}

function _SetBorderColor(control = "", color = "")
{
    var event = LIEvent.createEventForEventTypeControlValueStringSuffixValue("setBorderColor", control, color, "", "");
    eventArray.push(event);
};

function _SetControlValue(control = "", suffix = "", value = "")
{
    var valueString = "";
    
    // if known suffix is being used, null and empty values are allowed
    if (value || ["AnnotationImage", "BorderColor", "Strokes", "SelectedIndex"].includes(suffix)) {
    }
    else {
        valueString = suffix;
        suffix = "";
        if (Object.prototype.toString.call(valueString) === '[object Date]') {
            valueString = _FormatDate(valueString, "isoDateTime");
        }
    }
    var event = LIEvent.createEventForEventTypeControlValueStringSuffixValue("setControlValue", control, valueString, suffix, value);
    eventArray.push(event);
};

function _SetLayerVisibility(layer = "", visible = "")
{
    var event = LIEvent.createEventForEventTypeControlValueStringSuffixValue("setLayerVisibility", layer, visible, "", "");
    eventArray.push(event);
};

function _SetLayerEnabled(layer = "", enabled = "")
{
    var event = LIEvent.createEventForEventTypeControlValueStringSuffixValue("setLayerEnabled", layer, enabled, "", "");
    eventArray.push(event);
};

function _MessageBox(message = "", caption = "")
{
    if (!caption) {
        caption = "";
    }
    var event = LIEvent.createEventForEventTypeControlValueStringSuffixValue("messageBox", message, caption, "", "");
    eventArray.push(event);
};

function _GetClientType()
{
    // Enum declared in BuiltIns.js
    // var _ClientType = {
    //                        Html: 0,
    //                        iPad: 1,
    //                        Windows: 2,
    //                        PreCapture: 3
    //                        PreCaptureResponsive: 4
    //                     };
    return _ClientType.iPad;
};

// Added in INK-11881
function _GetClientTypeName()
{
    return "iPad";
};

function _Trace(text, severity) {
    var valueString = moment().format('YYYY-MM-DD HH:MM:SS.SSSS') + ' ' + getSeverityText(severity) + ' ' + text;
    var event = LIEvent.createEventForEventTypeControlValueStringSuffixValue("writeTraceLog", "", valueString, "", "");
    eventArray.push(event);
}

// Convert the severity enum value into a string.
function getSeverityText(severity) {
    switch (severity) {
        case _Severity.Info:
            return 'INFO';
        case _Severity.Warning:
            return 'WARN';
        case _Severity.Error:
            return 'ERR ';
        default:
            return '    ';
    }
}

function _JumpToPage(pageValue = "")
{
    // can check if int or string here in js, or later in swift
    var event = LIEvent.createEventForEventTypeControlValueStringSuffixValue("jumpToPage", pageValue, "", "", "");
    eventArray.push(event);
}

function _LaunchUrl(urlString = "")
{
    var event = LIEvent.createEventForEventTypeControlValueStringSuffixValue("launchUrl", urlString, "", "", "");
    eventArray.push(event);
};

function _IncludePageInFormFill(pageName = "")
{
    var event = LIEvent.createEventForEventTypeControlValueStringSuffixValue("includePageInFormFill", pageName, "", "", "");
    eventArray.push(event);
};

function _ExcludePageFromFormFill(pageName = "")
{
    var event = LIEvent.createEventForEventTypeControlValueStringSuffixValue("excludePageFromFormFill", pageName, "", "", "");
    eventArray.push(event);
};

function _IncludePageInDestination(pageName = "")
{
    var event = LIEvent.createEventForEventTypeControlValueStringSuffixValue("includePageInDestination", pageName, "", "", "");
    eventArray.push(event);
};

function _ExcludePageFromDestination(pageName = "")
{
    var event = LIEvent.createEventForEventTypeControlValueStringSuffixValue("excludePageFromDestination", pageName, "", "", "");
    eventArray.push(event);
};

function _GetFormStatus()
{
    return formStatus;
}

function _GetProcedures()
{
    var proceduresList = getProcedures();
    return proceduresList.sort(function (a, b)
                               { return a.toLowerCase().localeCompare(b.toLowerCase()); }
                               );
};

function _GetProcedureRisks(procedure = "")
{
    var riskList = getRisks(procedure);
    return riskList;
};

function _GetProcedureNotes(procedure = "", user = "")
{
    var noteList = getNotes(procedure, user);
    return noteList;
};

function _SaveProcedureNotes(procedure = "", user = "", notes = "")
{
    var event = LIEvent.createEventForEventTypeControlValueStringSuffixValue("saveProcedureNotes", procedure, user, notes, "");
    eventArray.push(event);
};

function _Speak(text = "", culture = "", extra = "")
{
    var event = LIEvent.createEventForEventTypeControlValueStringSuffixValue("speak", text, culture, extra, "", "");
    eventArray.push(event);
};
