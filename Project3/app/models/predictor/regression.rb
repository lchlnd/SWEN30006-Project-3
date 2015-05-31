require 'csv'
require 'matrix'

class Regression

	EPS = 0.005

	#Goes through each regression & returns a hash with highest corresponding r^2 value
	#Hash is returned in form {:type x, :a z, :b z, etc}
	#{:type log, :a 10, :b 2}
	#{:type polynomial, :degree 4, coefficients: [a0,a1,a2,a3], fit: x}
	def self.best_fit xvals, yvals
		#poly_nom
		best = {:fit => Float::MAX}

		#linear
		tmp = linear( xvals , yvals)
		if( tmp[:fit] < best[:fit] )
			best = tmp
		end
		puts "linear: #{tmp}"

		#log
		tmp = logarithmic( xvals , yvals)
		if( tmp[:fit] < best[:fit] )
			best = tmp
		end
		puts "log: #{tmp}"

		#poly_nom
		tmp = exponential( xvals , yvals)
		if( tmp[:fit] < best[:fit] )
			best = tmp
		end
		puts "exp #{tmp}"

		best[:mean] = (yvals.inject(0) { |sum, val| sum + val})/yvals.length
		best
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

		#Find the polynomial which gives the lowest variance.
		best_coefficients = poly_regress(xvals, yvals, 2)
		best_func = lambda { |x| best_coefficients.each.with_index.inject(0) { |f_y, (coeff, i)| f_y + coeff*x**i} }
		best_fit = measure_fit(xvals, yvals, best_func)

		for deg in (3..10)

			coefficients = poly_regress(xvals, yvals, deg)
			func = lambda { |x| coefficients.each.with_index.inject(0) { |f_y, (coeff, i)| f_y + coeff*x**i} }
			fit = measure_fit(xvals, yvals, func)

			if fit < best_fit
				best_fit = fit
				
				best_coefficients = []
				coefficients.each do |c|
					best_coefficients << c
				end
				best_func = lambda { |x| best_coefficients.each.with_index.inject(0) { |f_y, (coeff, i)| f_y + coeff*x**i} }
			end
		end
		puts "best function = #{best_func}"

		info = {:function => best_func, :fit => best_fit}
	end


	#Takes an array of x values and an array of corresponding y values and applies a linear regression
	# to find the equation of best fit.
	def self.linear xvals, yvals
		coefficients = poly_regress(xvals, yvals, 1).map { |coeff| coeff.round(2)}
		a = coefficients[1]
		b = coefficients[0]

		func = lambda { |x| a*x + b }
		fit = measure_fit(xvals, yvals, func)

		info = {:function => func, :fit => fit}
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

		func = lambda { |x| b*Math.log(x) + a}

		fit = measure_fit(xvals, yvals, func)

		info = {:function => func, :fit => fit}

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

		func = lambda { |x| a*Math.exp(b*x) }
		fit = measure_fit(xvals, yvals, func) 

		info = {:function => func, :fit => fit}
	end


	#Takes an array of x values, an array of corresponding y values and a lambda defining a function.
	#Returns the residual sum of squares of this data with trespect to the given function
	def self.measure_fit xvals, yvals, func
		y_model = []
		xvals.each {|x_i| y_model << func.call(x_i)}
		ss_res= ((yvals.zip(y_model)).inject(0) { |var, (y_i, f_i)| var + (y_i - f_i)**2 })

		return ss_res
	end

	private_class_method :measure_fit
	private_class_method :poly_regress
end



