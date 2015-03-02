module ActiveRecordExtension

  extend ActiveSupport::Concern

  # add your instance methods here
  # def foo
  #    "foo"
  # end

  # add your static(class) methods here
  module ClassMethods

    def icon
      'fa-pencil'
    end

    def displayable_cols
      self.new.attributes.keys - self.protected_attributes.to_a
    end

    def editable_cols
      displayable_cols - ['created_at', 'updated_at']
    end

    def sortable_cols
      displayable_cols
    end

    def hidden_cols
      []
    end

    def nested_cols
      self.attr_accessible[:default].to_a.collect{ |attr| attr if attr.match(/attributes$/) }.compact
    end

    def belongs_to_associations
      self.reflect_on_all_associations(:belongs_to).collect(&:name)
    end

    def has_many_associations
      self.reflect_on_all_associations(:has_many).collect(&:name)
    end

  end
end

# include the extension
ActiveRecord::Base.send(:include, ActiveRecordExtension)
