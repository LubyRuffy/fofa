ThinkingSphinx::Index.define :subdomain, :name => 'subdomain', :with => :active_record do
  # fields
  indexes ip
  indexes title
  indexes header
  indexes host
  indexes body

  # attributes
  has id, lastupdatetime
end

#ThinkingSphinx::Index.define :idx1, :name => 'idx1', :with => :active_record do
#  # fields
#  indexes ip
#  indexes title
#  indexes header
#  indexes host
#  indexes body
#
#  # attributes
#  has id, lastupdatetime
#end

