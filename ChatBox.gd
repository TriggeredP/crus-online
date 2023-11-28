extends PanelContainer

onready var textBox = $VBoxContainer/PanelContainer/RichTextLabel
onready var lineEdit = $VBoxContainer/LineEdit
onready var labelText = $VBoxContainer/Label

onready var parent = get_node("../../")

var sizeRatio = 16

func _ready():
	hide()

func _physics_process(delta):
	sizeRatio = 16 * (Global.resolution[0] / 1280)
	
	textBox.get_font("normal_font").size = sizeRatio
	lineEdit.get_font("font").size = sizeRatio
	labelText.get_font("font").size = sizeRatio

remote func send_message(message, author, img = null, color = null):
	var rawText = '\n'
	
	if img != null:
		rawText = rawText + '[img=32]' + img + '[/img] '
	
	if color != null:
		rawText = rawText + '[color=' + color + ']'
	
	rawText = rawText + author + ': ' + message
	
	print("message recived")
	print(message,author,img,color)
	textBox.bbcode_text = textBox.bbcode_text + rawText
	print(rawText)
	print(textBox.bbcode_text)

func _text_entered(new_text):
	rpc_unreliable("send_message",new_text,parent.my_info.nickname)
	send_message(new_text,parent.my_info.nickname)
	lineEdit.text = ""

func open_chat(type):
	show()
	$"../OpenChat".button_disable()
	$"../CloseChat".button_enable()

func close_chat(type):
	hide()
	$"../OpenChat".button_enable()
	$"../CloseChat".button_disable()
