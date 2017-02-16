# This is a temporary script.
# This script might not be permanently included in the git.
# This script should, however, be able to handle files where the JSON gem fails.

require 'mini_magick'

file = ARGV.join(' ')

def to_layer(default_color, pixels)
	[
		'{',
			'"default_color":' << "#{to_color(default_color)},",
			'"pixels":' << '[',
				pixels.join(','),
			']',
		'}'
	].join
end
def to_pixel(x, y, color)
	[
		'{',
			'"position":' << "#{to_pos(x,y)},",
			'"color":' << "#{to_color(color)}",
		'}'
	].join
end
def to_pos(x,y)
	[
		'{',
			'"x":' << "#{x},",
			'"y":' << "#{y}",
		'}'
	].join
end
def to_color(color)
	[
		'{',
			'"red":' << "#{color[0]},",
			'"green":' << "#{color[1]},",
			'"blue":' << "#{color[2]},",
			'"alpha":' << "#{color[3]}",
		'}'
	].join
end

def version
	'1.0'
end
def transparency
	true
end
def size(width,height)
	[
		'{',
			'"width":' << "#{width},",
			'"height":' << "#{height}",
		'}'
	].join
end
def to_assembly(version, transparency, size, layers)
	[
		'{',
			'"version":' << "\"#{version}\",",
			'"transparency":' << "#{transparency},",
			'"size":' << "#{size},",
			'"layers":' << '[',
				layers.join(','),
			']',
		'}'
	].join
end

def each_pixel(ary, &block)
	ary.each.with_index {|obj,x|
		obj.each.with_index {|color,y|
			yield x,y,color
		}
	}
end
def each_pixel_pop(ary, &block)
	ary.length.times {|x|
		ary.delete_at(0).each.with_index {|color,y|
			yield x,y,color
		}
	}
end
def most_common_color(ary)
	combinations = {}
	each_pixel(ary) {|_x,_y,color|
		combinations[color] ||= 0
		combinations[color] += 1
	}
	highest_color = [0,0,0,255]
	highest_count = 0
	combinations.each_pair {|c,v|
		if v > highest_count
			highest_color = c
			highest_count = v
		end
	}
	highest_color
end

MiniMagick.configure do |config|
	config.cli = :imagemagick
	
	# If you're having trouble with tools not being found, uncomment this next line
	# and place the required files within the same directory as this script.
	#config.cli_path = __dir__
end

time_started = Time.now.to_f

i = MiniMagick::Image.new(file)
width = i.width
height = i.height
i = nil

puts "Converting to RGBA..."
image = MiniMagick::Tool::Convert.new do |convert|
	convert << file
	convert << "rgba:-"
end


puts "Slicing and dicing..."
ary = []
last_x2 = -4
height.times {|y|
	y2 = (width * y * 4)
	width.times {|x|
		ary[x] ||= []
		x2 = (y2 + (x * 4))
		bytes_to_grab = x2..(x2+3)
		ary[x][y] = begin
									image[bytes_to_grab].bytes
								rescue
									[0,0,0,0] # Transparent data at the end of a PNG file
								end
		
		ary[x][y] = [0,0,0,0] if ary[x][y].empty?
	}
}

puts "Determining most common color..."
default_color = most_common_color(ary)

puts "Converting to pixels..."
pixels = []
each_pixel_pop(ary) {|x,y,color|
	next if color == default_color
	pixels << to_pixel(x,y,color)
}

puts "Putting it all together..."
assembly = to_assembly(
	version,
	transparency,
	size(width, height),
	[to_layer(default_color, pixels)]
)
pixels = nil

#puts "Generating the JSON..."
#assembly = JSON.generate(assembly)

puts "Saving your file..."
File.write("#{file}.jsng", assembly)

time_to_complete = Time.now.to_f - time_started
puts "Done. Took #{time_to_complete} seconds."
