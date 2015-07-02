require 'active_record'
require 'sqlite3'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: './magellan.db', pool: 1000, reaping_frequency: 10)

puts ActiveRecord::Base.connection.tables

class Machine < ActiveRecord::Base
	has_and_belongs_to_many :drinks
	has_and_belongs_to_many :payments
	has_many :comments
	
	def loc
		Location.new(self.location)
	end
	
	def distance_from(user_loc)
		self.loc.distance_to(user_loc)
	end
	
end

class Payment < ActiveRecord::Base
	has_and_belongs_to_many :machines
	has_many :drinks, through: :drinks_machines
end

class Drink < ActiveRecord::Base
	has_and_belongs_to_many :machines
	has_many :payments, through: :machines_payments
end

class Comment < ActiveRecord::Base
	belongs_to :machine
	
	def pretty_date
		now = Time.new
		diff = now - self.created_at
		day_diff = ((now - self.created_at) / 86400).floor
 
		day_diff == 0 && (
			diff < 60 && "just now" ||
			diff < 120 && "1 minute ago" ||
			diff < 3600 && (diff / 60).floor.to_s + " minutes ago" ||
			diff < 7200 && "1 hour ago" ||
			diff < 86400 && (diff/3600).floor.to_s + " hours ago") ||
		day_diff == 1 && "Yesterday" ||
		day_diff < 7 && day_diff.to_s + " days ago" ||
		day_diff < 31 && (day_diff / 7).ceil.to_s + " weeks ago";
	end

end

class MachineFinder

attr_accessor :machine_list, :machine_list_with_distance

	def initialize(user_loc, drink, payment)
		@machine_list = Machine.joins(:drinks,:payments).where("drinks.id = ? and payments.id = ?", drink, payment)
		sort_machine_list(user_loc) unless @machine_list.empty?
	end
	
	def sort_machine_list(user_loc)
		@machine_list_with_distance = {}
		@machine_list.each do |m|
			@machine_list_with_distance.merge!(m => m.distance_from(user_loc))
		end
		@machine_list_with_distance = @machine_list_with_distance.sort_by{ |machine, distance| distance}
	end
	
	
end
