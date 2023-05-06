extends Control

@onready var _texture: TextureRect = $Margin/HBox/Right/Middle/Panel2/Texture2D
@onready var _textureRed: TextureRect = $Margin/HBox/Right/Middle/Panel1/Red
@onready var _textureGreen: TextureRect = $Margin/HBox/Right/Top/Panel/Green
@onready var _textureBlue: TextureRect = $Margin/HBox/Right/Middle/Panel3/Blue
@onready var _preview: ColorRect = $Margin/HBox/Right/Bottom/Panel/Preview
@onready var _big: ColorRect = $Big

@onready var _colorEdit: LineEdit = $Margin/HBox/Left/Settings/Color/LineEdit
@onready var _colorPicker: ColorPickerButton = $Margin/HBox/Left/Settings/Color/ColorPicker
@onready var _seedEdit: SpinBox = $Margin/HBox/Left/Settings/Seed/SpinBox
@onready var _seedSlider: HSlider = $Margin/HBox/Left/Settings/Seed/HSlider
@onready var _octavesEdit: SpinBox = $Margin/HBox/Left/Settings/Octaves/SpinBox
@onready var _octavesSlider: HSlider = $Margin/HBox/Left/Settings/Octaves/HSlider
@onready var _periodEdit: SpinBox = $Margin/HBox/Left/Settings/Period/SpinBox
@onready var _periodSlider: HSlider = $Margin/HBox/Left/Settings/Period/HSlider
@onready var _persistenceEdit: SpinBox = $Margin/HBox/Left/Settings/Persistence/SpinBox
@onready var _persistenceSlider: HSlider = $Margin/HBox/Left/Settings/Persistence/HSlider
@onready var _lacunarityEdit: SpinBox = $Margin/HBox/Left/Settings/Lacunarity/SpinBox
@onready var _lacunaritySlider: HSlider = $Margin/HBox/Left/Settings/Lacunarity/HSlider

@onready var _generateButton: Button = $Margin/HBox/Left/Buttons/Generate
@onready var _resetButton: Button = $Margin/HBox/Left/Buttons/Reset
@onready var _saveButton: Button = $Margin/HBox/Left/Buttons/Save

@export var _size := 128
@export var _seedMax := 65535
@export var _path := "res://PixelInterface/GenerateTexture.png"
@export var _noise : FastNoiseLite

var _output : Image

func _ready() -> void:
	_colorEdit.connect("text_changed", Callable(self, "_colorEditChanged"))
	_colorPicker.connect("color_changed", Callable(self, "_colorPickerChanged"))
	_seedSlider.share(_seedEdit)
	_seedEdit.connect("value_changed", Callable(self, "_seedEditChanged"))
	_seedSlider.connect("value_changed", Callable(self, "_seedSliderChanged"))
	_octavesSlider.share(_octavesEdit)
	_octavesEdit.connect("value_changed", Callable(self, "_octavesEditChanged"))
	_octavesSlider.connect("value_changed", Callable(self, "_octavesSliderChanged"))
	_periodSlider.share(_periodEdit)
	_periodEdit.connect("value_changed", Callable(self, "_periodEditChanged"))
	_periodSlider.connect("value_changed", Callable(self, "_periodSliderChanged"))
	_persistenceSlider.share(_persistenceEdit)
	_persistenceEdit.connect("value_changed", Callable(self, "_persistenceEditChanged"))
	_persistenceSlider.connect("value_changed", Callable(self, "_persistenceSliderChanged"))
	_lacunaritySlider.share(_lacunarityEdit)
	_lacunarityEdit.connect("value_changed", Callable(self, "_lacunarityEditChanged"))
	_lacunaritySlider.connect("value_changed", Callable(self, "_lacunaritySliderChanged"))
	_generateButton.connect("pressed", Callable(self, "_generatePressed"))
	_resetButton.connect("pressed", Callable(self, "_resetPressed"))
	_saveButton.connect("pressed", Callable(self, "_savePressed"))
	_noise = FastNoiseLite.new()
	_preview.get_material().set_shader_parameter("color", Color.WHITE)
	_big.get_material().set_shader_parameter("color", Color.WHITE)
	_output = Image.create(_size, _size, false, Image.FORMAT_RGBA8)
	call_deferred("_loadSettings")

func _generatePressed() -> void:
	var old := _noise.seed
	_noise.seed += randi() % _seedMax
	var image1 := _noise.get_seamless_image(_size, _size)
	_noise.seed += randi() % _seedMax
	var image2 := _noise.get_seamless_image(_size, _size)
	_noise.seed += randi() % _seedMax
	var image3 := _noise.get_seamless_image(_size, _size)
	_noise.seed = old;
	for y in range(_size):
		for x in range(_size):
			var r = image1.get_pixel(x, y).r
			var g = image2.get_pixel(x, y).r
			var b = image3.get_pixel(x, y).r
			_output.set_pixel(x, y, Color(r, g, b))
	var new = ImageTexture.create_from_image(_output)
	_texture.texture = new
	_textureRed.texture = new
	_textureGreen.texture = new
	_textureBlue.texture = new
	_preview.get_material().set_shader_parameter("noise", new)
	_big.get_material().set_shader_parameter("noise", new)

func _resetPressed() -> void:
	_noise = FastNoiseLite.new()
	_preview.get_material().set_shader_parameter("color", Color.WHITE)
	_big.get_material().set_shader_parameter("color", Color.WHITE)
	_loadSettings()

func _savePressed() -> void:
	_output.save_png(_path)

func _loadSettings() -> void:
	var color : Color = _preview.get_material().get_shader_parameter("color")
	_colorEdit.text = color.to_html()
	_colorPicker.color = color
	_seedEdit.value = _noise.seed
	_seedSlider.value = _noise.seed
	_octavesEdit.value = _noise.fractal_octaves
	_octavesSlider.value = _noise.fractal_octaves
	# _periodEdit.value = _noise.period
	# _periodSlider.value = _noise.period
	# _persistenceEdit.value = _noise.persistence
	# _persistenceSlider.value = _noise.persistence
	# _lacunarityEdit.value = _noise.lacunarity
	# _lacunaritySlider.value = _noise.lacunarity
	# TODO: !?
	_generatePressed()

func _colorEditChanged(value: String) -> void:
	var v := Color(value)
	_preview.get_material().set_shader_parameter("color", v)
	_big.get_material().set_shader_parameter("color", v)
	_colorPicker.color = v

func _colorPickerChanged(value: Color) -> void:
	_preview.get_material().set_shader_parameter("color", value)
	_big.get_material().set_shader_parameter("color", value)
	_colorEdit.text = value.to_html()

func _seedEditChanged(value: int) -> void:
	_noise.seed = value
	_seedSlider.value = value
	call_deferred("_generatePressed")

func _seedSliderChanged(value: float) -> void:
	_noise.seed = int(value)
	_seedEdit.value = value
	call_deferred("_generatePressed")

func _octavesEditChanged(value: float) -> void:
	_noise.fractal_octaves = int(value)
	_octavesSlider.value = value
	call_deferred("_generatePressed")

func _octavesSliderChanged(value: float) -> void:
	_noise.fractal_octaves = int(value)
	_octavesEdit.value = value
	call_deferred("_generatePressed")

func _periodEditChanged(value: float) -> void:
	_noise.period = value
	_periodSlider.value = value
	call_deferred("_generatePressed")

func _periodSliderChanged(value: float) -> void:
	_noise.period = value
	_periodEdit.value = value
	call_deferred("_generatePressed")

func _persistenceEditChanged(value: float) -> void:
	_noise.persistence = value
	_persistenceSlider.value = value
	call_deferred("_generatePressed")

func _persistenceSliderChanged(value: float) -> void:
	_noise.persistence = value
	_persistenceEdit.value = value
	call_deferred("_generatePressed")

func _lacunarityEditChanged(value: float) -> void:
	_noise.lacunarity = value
	_lacunaritySlider.value = value
	call_deferred("_generatePressed")

func _lacunaritySliderChanged(value: float) -> void:
	_noise.lacunarity = value
	_lacunarityEdit.value = value
	call_deferred("_generatePressed")
