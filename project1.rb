require 'CSV'
require 'matrix'

class Regression

	EPS = 0.005

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
		coefficients = ((mx.t * mx).inv * mx.t * my).transpose.to_a[0]
	end


	#Takes an array of x values and an array of corresponding y values and applies a polynomial
	# regression of each degree between 1 and 10 (inclusive), printing the equation with the best fit. 
	def self.polynomial xvals, yvals
		
		best_r2 = -Float::MAX
		#Find the polynomial which gives the lowest variance.
		for deg in (2..10)
			coefficients = poly_regress(xvals, yvals, deg).map { |coeff| coeff.round(2)}
			r2 = r_squared(xvals, yvals) { |x| coefficients.each.with_index.inject(0) { |f_y, (coeff, i)| f_y + coeff*x**i} }
			if r2 > best_r2
				best_r2 = r2
				puts "best r2 =", r2
				best_coeff = coefficients
			end
		end

		#Convert the polynomial into a string.  Do not include a term if its coefficient is less than or equal to EPS (=0.005), 
		# unless it is the coefficient of the highest order term.
		poly_string = ""
		best_coeff.to_enum.with_index.reverse_each do |coeff, i| 
			if i == (best_coeff.length - 1)
				poly_string.concat("%.2fx^#{i} " % coeff)
			elsif i == 0
				poly_string.concat("%c %.2f " % [coeff > 0 ? '+' : '-', coeff.abs])
			elsif i == 1
				poly_string.concat("%c %.2fx " % [coeff>0? '+' : '-', coeff.abs])
			else
				poly_string.concat("%c %.2fx^#{i} " % [coeff>0 ? '+' : '-', coeff.abs])
			end
		end
		puts poly_string
		puts "R squared = #{best_r2}"	
	end


	#Takes an array of x values and an array of corresponding y values and applies a linear regression
	# to find the equation of best fit.
	def self.linear xvals, yvals
		coefficients = poly_regress(xvals, yvals, 1).map { |coeff| coeff.round(2)}
		a = coefficients[1]
		b = coefficients[0]

		
		puts "%.2fx %c %.2f" % [a, b >= 0 ? '+' : '-', b.abs]
		r2 = r_squared(xvals, yvals) { |x| a*x + b }
		puts "R squared = #{r2}"
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

		puts "%.2f*ln(x) %c %.2f" % [b, a>=0 ? '+' : '-', a.abs]

		r2 = r_squared(xvals, yvals) { |x| b*Math.log(x) + a}
		puts "R squared = #{r2}"

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

		puts "%.2f*e^%.2fx" % [a, b]

		r2 = r_squared(xvals, yvals) { |x| a*Math.exp(b*x) }
		puts "R squared = #{r2}"
	end


	#Takes an array of x values, an array of corresponding y values and a block defining a function that.
	#Returns the R^2 value of these arguments.
	def self.r_squared xvals, yvals
		if block_given?
			y_model = []
			xvals.each {|x_i| y_model << yield(x_i)}
			ss_res= ((yvals.zip(y_model)).inject(0) { |var, (y_i, f_i)| var + (y_i - f_i)**2 })
			mean = (yvals.inject(0) { |sum, y_i| sum + y_i })/yvals.length
			ss_tot = yvals.inject(0) { |sum, y_i| sum + (y_i - mean)**2 }
			r2 = 1 - ss_res/ss_tot
		else
			puts "Error: Function 'Regression.r_squared' requires a block argument."
			:error
		end
	end

	private_class_method :r_squared
	private_class_method :poly_regress

end




data = CSV.read(ARGV[0], {:headers => true, :converters => :numeric})
begin
	Regression.public_send(:"#{ARGV[1]}", data['time'], data['datapoint'])
rescue Math::DomainError=>e
	puts "Cannot perform #{ARGV[1]} regression on this data"
	:error
rescue NoMethodError=>e
	puts "Error: second command line argument must be one of 'polynomial', 'linear', 'exponential' or 'logarithmic'"
	:error
end

