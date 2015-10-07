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

    def protected_attributes
      ['id', 'created_at', 'updated_at']
    end

    def displayable_cols
      self.new.attributes.keys - protected_attributes
    end

    def editable_cols
      displayable_cols - ['created_at', 'updated_at']
    end

    def sortable_cols
      displayable_cols
    end

    def default_sort_cols
      # [[:id, 'ASC']]
      []
    end

    def hidden_cols
      []
    end

    def nested_cols
      res = ActiveSupport::OrderedHash.new
      
      cols = self.attr_accessible[:default].to_a.collect{ |attr| attr if attr.match(/attributes$/) }.compact
      cols.each do |col|
        self.reflect_on_all_associations.each do |r|
          name = r.name.to_s
          col_name = col.to_s.gsub('_attributes', '')
          if name == col_name
            res[name] = (r.options[:class_name] ? r.options[:class_name] : col_name.to_s.singularize.camelize)
          end
        end
      end

      res
    end

    def all_associations(macro=nil)
      self.reflect_on_all_associations(macro)
    end

    def all_associations_names(macro=nil)
      all_associations(macro).collect(&:name)
    end

    def all_associations_ids(macro=nil)
      res = []
      all_associations(macro).each do |association|
        if association.options and association.options[:foreign_key]
          res << association.options[:foreign_key]
        else
          res << association.name.to_s.foreign_key.to_sym
        end
      end
      res
    end


    # DEPRECATED
    def belongs_to_associations
      self.reflect_on_all_associations(:belongs_to).collect(&:name)
    end

    # DEPRECATED
    def has_many_associations
      self.reflect_on_all_associations(:has_many).collect(&:name)
    end

  end
end

# include the extension
ActiveRecord::Base.send(:include, ActiveRecordExtension)
