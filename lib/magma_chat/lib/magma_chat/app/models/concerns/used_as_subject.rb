module UsedAsSubject
  extend ActiveSupport::Concern

  included do
    has_many :thoughts, as: :subject, dependent: :destroy
  end

  def to_subject_name
    "#{self.class.name} (#{name}): #{id}"
  end
end
