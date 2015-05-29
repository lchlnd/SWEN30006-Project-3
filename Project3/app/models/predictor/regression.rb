require 'CSV'
require 'matrix'

class Regression

	EPS = 0.005

	#Goes through each regression & returns a hash with highest corresponding r^2 value
	#Hash is returned in form {:type x, :a z, :b z, etc}
	#{:type log, :a 10, :b 2}
	#{:type polynomial, :degree 4, coefficients: [a0,a1,a2,a3], r2: x}
	def self.best_fit xvals, yvals
		best_r2 = -Float::MAX
		info = {}
		tmp ={}
		#poly_nom
		tmp = polynomial( xvals , yvals)
		if( tmp[:r2] > best_r2 )
			info = tmp
			best_r2 = tmp[:r2]
		end
		puts "poly: #{tmp}"
		#linear
		tmp = linear( xvals , yvals)
		if( tmp[:r2] > best_r2 )
			info = tmp
			best_r2 = tmp[:r2]
		end
		puts "linear: #{tmp}"
		#log
		tmp = logarithmic( xvals , yvals)
		if( tmp[:r2] > best_r2 )
			info = tmp
			best_r2 = tmp[:r2]
		end
		puts "log: #{tmp}"
		#poly_nom
		tmp = exponential( xvals , yvals)
		if( tmp[:r2] > best_r2 )
			info = tmp
			best_r2 = tmp[:r2]
		end
		puts "exp #{tmp}"
		info
	end

	#Takes an array of x values, an array of corresponding y values and a degree and applies a polynomial
	# regression of the given degree. Returns the coefficients of the polynomial.
	#Function copied from:  
	# => SWEN30006 Semester 1 2015 Project 1
	# => 'Getting to Grips with Ruby'
	# => Author: Mat Blair
	def self.poly_regress xvals, yvals, degree 
		
		x_data = xvals.map { |x_i| (0..degree).map{ |pow| (x_i**pow).to_f } }
		mx = Matrix[*x_data]
		my = Matrix.column_vector(yvals)
		temp = mx.t * mx
		coefficients = (temp.inv * mx.t * my).transpose.to_a[0]
	end


	#Takes an array of x values and an array of corresponding y values and applies a polynomial
	# regression of each degree between 1 and 10 (inclusive), printing the equation with the best fit. 
	def self.polynomial xvals, yvals
		
		best_r2 = -Float::MAX
		#Find the polynomial which gives the lowest variance.
		for deg in (2..10)

			coefficients = poly_regress(xvals, yvals, deg)
			func = Proc.new{ |x| coefficients.each.with_index.inject(0) { |f_y, (coeff, i)| f_y + coeff*x**i} }
			r2 = r_squared(xvals, yvals, func)

			if r2 > best_r2
				best_r2 = r2
				
				best_coefficients = []
				coefficients.each do |c|
					best_coefficients << c
				end
				best_func = lambda { |x| best_coefficients.each.with_index.inject(0) { |f_y, (coeff, i)| f_y + coeff*x**i} }
			end
		end


		info = {:function => best_func, :r2 => best_r2}

		#Convert the polynomial into a string.  Do not include a term if its coefficient is less than or equal to EPS (=0.005), 
		# unless it is the coefficient of the highest order term.
		# poly_string = ""
		# best_coeff.to_enum.with_index.reverse_each do |coeff, i| 
		# 	if i == (best_coeff.length - 1)
		# 		poly_string.concat("%.2fx^#{i} " % coeff)
		# 	elsif i == 0
		# 		poly_string.concat("%c %.2f " % [coeff > 0 ? '+' : '-', coeff.abs])
		# 	elsif i == 1
		# 		poly_string.concat("%c %.2fx " % [coeff>0? '+' : '-', coeff.abs])
		# 	else
		# 		poly_string.concat("%c %.2fx^#{i} " % [coeff>0 ? '+' : '-', coeff.abs])
		# 	end
		# end
		info

	end


	#Takes an array of x values and an array of corresponding y values and applies a linear regression
	# to find the equation of best fit.
	def self.linear xvals, yvals
		coefficients = poly_regress(xvals, yvals, 1).map { |coeff| coeff.round(2)}
		a = coefficients[1]
		b = coefficients[0]

		
		#puts "%.2fx %c %.2f" % [a, b >= 0 ? '+' : '-', b.abs]
		func = lambda { |x| a*x + b }
		r2 = r_squared(xvals, yvals, func)
		#puts "R squared = #{r2}"

		info = {:function => func, :r2 => r2}
	end


	#Takes an array of x values and an array of corresponding y values and applies a
	#regression to find the exponential equation of best fit.
	def self.logarithmic xvals, yvals

		sum_y = yvals.inject(0) { |sum, y| sum + y }
		sum_ln_x = xvals.inject(0) { |sum, x| sum + Math.log(x) }
		sum_ln_x2 = xvals.inject(0) {|sum, x| sum + Math.log(x)**2 }

		sum_y_ln_x = 0
		xvals.zip(yvals) { |row| sum_y_ln_x += row[1]*Math.log(row[0]) }

		n = xvals.length
		b = (n*sum_y_ln_x - sum_y*sum_ln_x)/(n*sum_ln_x2 - sum_ln_x**2)
		a = ((sum_y - b*sum_ln_x)/n).round(2)
		b = b.round(2)

		coefficients = [a,b]
		#puts "%.2f*ln(x) %c %.2f" % [b, a>=0 ? '+' : '-', a.abs]
		func = lambda { |x| b*Math.log(x) + a}

		r2 = r_squared(xvals, yvals, func)
		#puts "R squared = #{r2}"

		info = {:function => func, :r2 => r2}

	end


	#Takes an array of x values and an array of corresponding y values and applies a
	#regression to find the exponential equation of best fit.
	def self.exponential xvals, yvals
		sum_ln_y = yvals.inject(0) { |sum, elem| sum + Math.log(elem) }
		sum_x2 = xvals.inject(0) { |sum, elem| sum + elem**2 }
		sum_x = xvals.inject(0) { |sum, elem| sum + elem }

		sum_x_ln_y = 0
		xvals.zip(yvals) { |row| sum_x_ln_y += row[0]*Math.log(row[1]) }

		n = xvals.length
		a = Math.exp((sum_ln_y*sum_x2 - sum_x*sum_x_ln_y)/(n*sum_x2 - sum_x**2)).round(2)
		b = (n*sum_x_ln_y - sum_x*sum_ln_y)/(n*sum_x2 - sum_x**2).round(2)
		coefficients = [a,b]
		#puts "%.2f*e^%.2fx" % [a, b]
		func = lambda { |x| a*Math.exp(b*x) }
		r2 = r_squared(xvals, yvals, func) 
		#puts "R squared = #{r2}"
		info = {:function => func, :r2 => r2}
	end


	#Takes an array of x values, an array of corresponding y values and a block defining a function that.
	#Returns the R^2 value of these arguments.
	def self.r_squared xvals, yvals, func
		y_model = []
		xvals.each {|x_i| y_model << func.call(x_i)}
		ss_res= ((yvals.zip(y_model)).inject(0) { |var, (y_i, f_i)| var + (y_i - f_i)**2 })
		mean = (yvals.inject(0) { |sum, y_i| sum + y_i })/yvals.length
		ss_tot = yvals.inject(0) { |sum, y_i| sum + (y_i - mean)**2 }
		#puts "res = #{ss_res}"
		#puts "tot = #{ss_tot}"
		r2 = 1 - ss_res/ss_tot
	end

	private_class_method :r_squared
	private_class_method :poly_regress
end



