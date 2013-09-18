require_relative './active_record_lite/associatable'
require_relative './active_record_lite/db_connection'
require_relative './active_record_lite/mass_object'
require_relative './active_record_lite/searchable'
require_relative './active_record_lite/sql_object'

# class Object
#
#   def new_attr_accessor(*symbols)
#     symbols.each do |symbol|
#     #create setter and getter methods
#       my_attribute = symbol.to_s
#
#       define_method("#{my_attribute}") do
#         instance_variable_get("@#{my_attribute}")
#       end
#
#       define_method("#{my_attribute}=") do |value|
#         instance_variable_set("@#{my_attribute}", value)
#       end
#     end
#   end
#
# end