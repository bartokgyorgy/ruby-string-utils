class String
	def remove_chars chars
		tmp = self.dup
		chars.each_char do |c|
			tmp.gsub!(c, "")
		end
		return tmp
	end
	
	def remove_chars! chars
		chars.each_char do |c|
			self.gsub!(c, "")
		end
		return self
	end
	
	def nospace
		return gsub(" ", "")
	end
	
	def nospace!
		return gsub!(" ", "")
	end
	
	def unindent(policyrequest = nil)
		policy = policyrequest
		if policy != :extra then policy = :plain end
		tmp = self.dup
		orss = tmp.size
		tmp.lstrip!
		stss = tmp.size
		indent = orss - stss
		if policy == :extra
			
		end
		return [indent, tmp]
	end
	
	def unindent!
		orss = self.size
		lstrip!
		stss = self.size
		indent = orss - stss
		return [indent, self]
	end
	
	def include_any?(str = "")
		result = false
		last = str.size - 1
		index = 0
		cont = index <= last
		while cont do
			if self.include? str[index]
				result = true
				cont = false
			end
			index += 1
			if index > last then cont = false end
		end
		return result
	end
	
	def int_eval_all
		chartypes = ""
		last = self.size - 1
		
		# make type mask
		self.each_char do |char| # v: valid, s: sign, o: other
			chartype = "o"
			if "0123456789".include? char then chartype = "v" end
			if "+-".include? char then chartype = "s" end
			chartypes += chartype
		end
		
		# replace invalid signs
		(0..last).each do |index|
			if chartypes[index] == "s"
				if index == last
					chartypes[index] = "o"
				else
					if chartypes[index+1] != "v" then chartypes[index] = "o" end
				end
			end
		end
		
		# separate distinct chunks
		chunks = []
		(0..last).each do |index|
			char = chartypes[index]
			change = false
			if chunks.size == 0
				change = true
			else
				if chunks[-1][0] != char
					two = chunks[-1][0] + char
					# no change if two is "so" or "sv"
					if !["so", "sv"].include? two then change = true end
				end
			end
			if change
				if char == "s" then char = "v" end
				chunks << [char, index, index]
			else
				chunks[-1][2] = index
			end
		end
		
		# sdd valid chunks to result
		result = []
		chunks.each do |chunk|
			if chunk[0] == "v" then result << self[chunk[1]..chunk[2]].to_i end
		end
		
		return result
	end
	
	def int_eval_strict
		valid = true
		vchars = "0123456789+-"
		last = self.size-1
		index = 0
		cont = index <= last
		result = nil
		while cont do
			if !(vchars.include? self[index])
				valid = false
				cont = false
			end
			if index == 0 then vchars = vchars[0..-3] end
			index += 1
			if index > last then cont = false end
		end
		if valid then result = self.to_i end
		return result
	end
	
	def int_eval_front
		vchars = "0123456789+-"
		last = self.size-1
		index = 0
		cont = index <= last
		result = nil
		while cont do
			if !(vchars.include? self[index])
				cont = false
			end
			if index == 0 then vchars = vchars[0..-3] end
			index += 1
			if index > last then cont = false end
		end
		if (index > 1) and (self[0..index-1].include_any? "0123456789")
			result = self[0..index-1].to_i
		end
		return result
	end
	
	alias_method :int_eval, :int_eval_front
	
	def line_wrap width
		width = width.to_s.int_eval_front
		return gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n")
	end
	
	def line_wrap! width
		width = width.to_s.int_eval_front
		return gsub!(/(.{1,#{width}})(\s+|\Z)/, "\\1\n")
	end
	
	def frame_wrap(width, policyrequest = nil)
		policy = policyrequest
		if ![:top, :bottom, :none].include? policy then policy = :both end
		width = width.to_s.int_eval_front
		lines = self.gsub(/(.{1,#{width-4}})(\s+|\Z)/, "\\1\n").split("\n")
		result = []
		lines.each do |line|
			result << "| " + line.ljust(width-4, " ") + " |"
		end
		if [:both, :top].include? policy
			result.unshift("+".ljust(width - 1, "-") + "+")
		end
		if [:both, :bottom].include? policy
			result << ("+".ljust(width - 1, "-") + "+")
		end
		return result.join("\n")
	end
	
	def frame_wrap!(width, policyrequest = nil)
		tmp = frame_wrap(width, policyrequest)
		self.slice(0..-1)
		gsub!(self, "a")
		gsub!("a", tmp)
		return self
	end
end

class Integer
	def to_serial
		post = "th"
		irregular = {1 => "st", 2 => "nd", 3 => "rd"}
		digit0 = self % 10
		digit00 = self % 100
		if [1, 2, 3].include? digit0 then post = irregular[digit0] end
		if [11, 12, 13].include? digit00 then post = "th" end
		return self.to_s + post
	end
end
