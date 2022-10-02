var HTML;
var Data;

function sliderUpdated(event,ui) {
}

function getSliderValues() {
	let values = {
        turbo:$("#turbo").val(),
        airFuel:$("#airFuel").val(),
        brakeForce:$("#brakeForce").val(),
        trans:$("#trans").val(),
        drive:$("#drive").val(),
        brakeBias:$("#brakeBias").val()
    };
    console.log(values);
    return values;
}

function setSliderValues(vals) {
    let values = (vals) ? vals : {turbo:100,airFuel:100,brakeForce:100,trans:100,drive:Data.default.drive,brakeBias:Data.default.brakeBias};
	$(".slide").each(function(){
		if(values[this.id]!=null) {
			$(this).val(values[this.id]);
		}
	});
	sliderUpdated();
}

function menuToggle(bool,send=false) {
	if(bool) {
		$("body").show();
	} else {
		$("body").hide();
	} 
	if(send){
		$.post('https://t3_tunerchip/togglemenu', JSON.stringify({state:false}));
	}
}

$(function(){
	$("body").hide();
	$("#default").click(function(){setSliderValues();});	
	$("#submit").click(function(){
		initiateTyepwriter();
		$.post('https://t3_tunerchip/save', JSON.stringify({default: Data.default, values: getSliderValues()}));
	});
	$("#cancel").click(function(){
		menuToggle(false,true);
	});
	document.onkeyup = function (data) {
        if (data.which == 27) {
            menuToggle(false,true);
        }
    };
	window.addEventListener('message', function(event){
		if(event.data.type=="togglemenu") {
			menuToggle(event.data.state,false);
			if(event.data.data!=null) {
                if(!event.data.data.isTurbo){
                    $("#turbo-option").addClass("disabled");
                    $("#turbo").prop("disabled",true);
                } else {
                    $("#turbo-option").removeClass("disabled");
                    $("#turbo").prop("disabled",false);
                }
				Data = event.data.data;
				setSliderValues(event.data.data.values);
			}
		}
	});
});

$(document).ready(function() {
	var typewriter = document.getElementById("typewriter");
	HTML = typewriter.innerHTML;
	
	typewriter.innerHTML = "";
	
});

function initiateTyepwriter() {
    $(".ecutext-container").removeClass("hide");
	var t = document.getElementById("typewriter");
	
	typewriter = setupTypewriter(HTML, t);
	typewriter.type();
	
	toggleButton(1);
}

function finish() {
	toggleButton(0);
	$(".ecutext-container").addClass("hide");
}

function toggleButton(bool) {
	var btnSave = document.getElementById("submit");
	btnSave.disabled = bool;
}

function setupTypewriter(HTML, t) {
    t.innerHTML = "";

    var cursorPosition = 0,
        tag = "",
        writingTag = false,
        tagOpen = false,
        typeSpeed = 0,
    tempTypeSpeed = 0;


    var type = function() {
    
        if (writingTag === true) {
            tag += HTML[cursorPosition];
        }

        if (HTML[cursorPosition] === "<") {
            tempTypeSpeed = 0;
            if (tagOpen) {
                tagOpen = false;
                writingTag = true;
            } else {
                tag = "";
                tagOpen = true;
                writingTag = true;
                tag += HTML[cursorPosition];
            }
        }
        if (!writingTag && tagOpen) {
            tag.innerHTML += HTML[cursorPosition];
        }
        if (!writingTag && !tagOpen) {
            if (HTML[cursorPosition] === " ") {
                tempTypeSpeed = 0;
            }
            else {
                tempTypeSpeed = typeSpeed;
            }
            t.innerHTML += HTML[cursorPosition];
        }
        if (writingTag === true && HTML[cursorPosition] === ">") {
            tempTypeSpeed = typeSpeed;
            writingTag = false;
            if (tagOpen) {
                var newSpan = document.createElement("span");
                t.appendChild(newSpan);
                newSpan.innerHTML = tag;
                tag = newSpan.firstChild;
            }
        }

        cursorPosition += 1;
        if (cursorPosition < HTML.length - 1) {
            setTimeout(type, tempTypeSpeed);
        } else {
			finish();
		}

    };

    return {
        type: type
    };
}