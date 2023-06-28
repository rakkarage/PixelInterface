extends Control

@onready var _texture: TextureRect = $Margin/HBox/Right/Middle/Panel2/Texture2D
@onready var _texture_red: TextureRect = $Margin/HBox/Right/Middle/Panel1/Red
@onready var _texture_green: TextureRect = $Margin/HBox/Right/Top/Panel/Green
@onready var _texture_blue: TextureRect = $Margin/HBox/Right/Middle/Panel3/Blue
@onready var _preview: ColorRect = $Margin/HBox/Right/Bottom/Panel/Preview
@onready var _big: ColorRect = $Big

@onready var _color_edit: LineEdit = $Margin/HBox/Left/Settings/Color/LineEdit
@onready var _color_picker: ColorPickerButton = $Margin/HBox/Left/Settings/Color/ColorPicker
@onready var _seed_edit: SpinBox = $Margin/HBox/Left/Settings/Seed/SpinBox
@onready var _seed_slider: HSlider = $Margin/HBox/Left/Settings/Seed/HSlider
@onready var _octaves_edit: SpinBox = $Margin/HBox/Left/Settings/Octaves/SpinBox
@onready var _octaves_slider: HSlider = $Margin/HBox/Left/Settings/Octaves/HSlider
@onready var _frequency_edit: SpinBox = $Margin/HBox/Left/Settings/Frequency/SpinBox
@onready var _frequency_slider: HSlider = $Margin/HBox/Left/Settings/Frequency/HSlider
@onready var _gain_edit: SpinBox = $Margin/HBox/Left/Settings/Gain/SpinBox
@onready var _gain_slider: HSlider = $Margin/HBox/Left/Settings/Gain/HSlider
@onready var _lacunarity_edit: SpinBox = $Margin/HBox/Left/Settings/Lacunarity/SpinBox
@onready var _lacunarity_slider: HSlider = $Margin/HBox/Left/Settings/Lacunarity/HSlider

@onready var _generate_button: Button = $Margin/HBox/Left/Buttons/Generate
@onready var _reset_button: Button = $Margin/HBox/Left/Buttons/Reset
@onready var _save_button: Button = $Margin/HBox/Left/Buttons/Save

@export var _size := 128
@export var _path := "res://PixelInterface/GenerateTexture.png"
@export var _noise : FastNoiseLite

var _output : Image

func _ready() -> void:
	_color_edit.connect("text_changed", _colorEditChanged)
	_color_picker.connect("color_changed", _colorPickerChanged)
	_seed_slider.share(_seed_edit)
	_seed_edit.connect("value_changed", _seedEditChanged)
	_seed_slider.connect("value_changed", _seedSliderChanged)
	_octaves_slider.share(_octaves_edit)
	_octaves_edit.connect("value_changed", _octavesEditChanged)
	_octaves_slider.connect("value_changed", _octavesSliderChanged)
	_frequency_slider.share(_frequency_edit)
	_frequency_edit.connect("value_changed", _frequencyEditChanged)
	_frequency_slider.connect("value_changed", _frequencySliderChanged)
	_gain_slider.share(_gain_edit)
	_gain_edit.connect("value_changed", _gainEditChanged)
	_gain_slider.connect("value_changed", _gainSliderChanged)
	_lacunarity_slider.share(_lacunarity_edit)
	_lacunarity_edit.connect("value_changed", _lacunarityEditChanged)
	_lacunarity_slider.connect("value_changed", _lacunaritySliderChanged)
	_generate_button.connect("pressed", _generatePressed)
	_reset_button.connect("pressed", _resetPressed)
	_save_button.connect("pressed", _savePressed)
	_noise = FastNoiseLite.new()
	_preview.get_material().set_shader_parameter("color", Color.WHITE)
	_big.get_material().set_shader_parameter("color", Color.WHITE)
	_output = Image.create(_size, _size, false, Image.FORMAT_RGBA8)
	call_deferred("_loadSettings")

func _generatePressed() -> void:
	_noise.seed = randi()
	var image_1 := _noise.get_seamless_image(_size, _size, false, false, 0.333)
	_noise.seed += 1
	var image_2 := _noise.get_seamless_image(_size, _size, false, false, 0.333)
	_noise.seed += 2
	var image_3 := _noise.get_seamless_image(_size, _size, false, false, 0.333)
	for y in range(_size):
		for x in range(_size):
			var r = image_1.get_pixel(x, y).r
			var g = image_2.get_pixel(x, y).r
			var b = image_3.get_pixel(x, y).r
			_output.set_pixel(x, y, Color(r, g, b))
	var new = ImageTexture.create_from_image(_output)
	_texture.texture = new
	_texture_red.texture = new
	_texture_green.texture = new
	_texture_blue.texture = new
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
	_color_edit.text = color.to_html()
	_color_picker.color = color
	_seed_edit.value = _noise.seed
	_seed_slider.value = _noise.seed
	_octaves_edit.value = _noise.fractal_octaves
	_octaves_slider.value = _noise.fractal_octaves
	_frequency_edit.value = _noise.frequency
	_frequency_slider.value = _noise.frequency
	_gain_edit.value = _noise.fractal_gain
	_gain_slider.value = _noise.fractal_gain
	_lacunarity_edit.value = _noise.fractal_lacunarity
	_lacunarity_slider.value = _noise.fractal_lacunarity
	_generatePressed()

func _colorEditChanged(value: String) -> void:
	var v := Color(value)
	_preview.get_material().set_shader_parameter("color", v)
	_big.get_material().set_shader_parameter("color", v)
	_color_picker.color = v

func _colorPickerChanged(value: Color) -> void:
	_preview.get_material().set_shader_parameter("color", value)
	_big.get_material().set_shader_parameter("color", value)
	_color_edit.text = value.to_html()

func _seedEditChanged(value: int) -> void:
	_noise.seed = value
	_seed_slider.value = value
	call_deferred("_generatePressed")

func _seedSliderChanged(value: float) -> void:
	_noise.seed = int(value)
	_seed_edit.value = value
	call_deferred("_generatePressed")

func _octavesEditChanged(value: float) -> void:
	_noise.fractal_octaves = int(value)
	_octaves_slider.value = value
	call_deferred("_generatePressed")

func _octavesSliderChanged(value: float) -> void:
	_noise.fractal_octaves = int(value)
	_octaves_edit.value = value
	call_deferred("_generatePressed")

func _frequencyEditChanged(value: float) -> void:
	_noise.frequency = value
	_frequency_slider.value = value
	call_deferred("_generatePressed")

func _frequencySliderChanged(value: float) -> void:
	_noise.frequency = value
	_frequency_edit.value = value
	call_deferred("_generatePressed")

func _gainEditChanged(value: float) -> void:
	_noise.fractal_gain = value
	_gain_slider.value = value
	call_deferred("_generatePressed")

func _gainSliderChanged(value: float) -> void:
	_noise.fractal_gain = value
	_gain_edit.value = value
	call_deferred("_generatePressed")

func _lacunarityEditChanged(value: float) -> void:
	_noise.fractal_lacunarity = value
	_lacunarity_slider.value = value
	call_deferred("_generatePressed")

func _lacunaritySliderChanged(value: float) -> void:
	_noise.fractal_lacunarity = value
	_lacunarity_edit.value = value
	call_deferred("_generatePressed")
