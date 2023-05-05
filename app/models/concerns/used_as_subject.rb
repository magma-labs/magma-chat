module UsedAsSubject
  extend ActiveSupport::Concern

  def to_subject_name
    "#{self.class.name} (#{name}): #{id}"
  end
end
