class Subdomain < ActiveRecord::Base
  #set_table_name "subdomainaaaa"
  self.table_name="subdomain"

  def self.nocache_where(info)
    uncached do
      where(info)
    end
  end
end
