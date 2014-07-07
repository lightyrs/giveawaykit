class Audit < ActiveRecord::Base

  attr_accessible :was, :is, :comment

  belongs_to :auditable, polymorphic: true

  serialize :was
  serialize :is
end