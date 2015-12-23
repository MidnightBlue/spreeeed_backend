module ActsAsOptionTree
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def option_tree_key
      "option_tree/#{self.to_s}"
    end

    def to_option_tree(force_update=false)
      if force_update or !(option_tree = Rails.cache.read(option_tree_key))
        Rails.logger.debug("== Generated #{self.to_s} option tree ==")
        option_tree = _to_option_tree
        Rails.cache.write(option_tree_key, option_tree)
      end
      option_tree
    end

    def _to_option_tree
      res = {}
      roots.each do |node|
        res.merge!(to_tree(node))
      end
      res
    end

    def to_tree(node)
      res = {}
      if node.children.size > 0
        res[node.name] = Hash.new
        node.children.each do |child|
          res[node.name].merge!(to_tree(child))
        end
      else
        res[node.name] = node.id
      end
      res
    end

    def find_option_tree_path(option_tree, find_id)
      path, flag = try_to_find_option_tree_path(option_tree, find_id)
      path
    end

    def try_to_find_option_tree_path(option_tree, find_id, traversal_path=[], ident=' ', break_flag=false)
      # ident      *= 2

      if option_tree.is_a?(Integer)
        if option_tree != find_id
          traversal_path.pop
        end

        [traversal_path, break_flag]
      else
        option_tree.each do |name, option_tree_or_value|
          if break_flag
            # puts "#{ident} [return] #{traversal_path.join(' > ')}, f = #{break_flag}"
            return [traversal_path, break_flag] 
          end
    
          traversal_path << name
          before_traversal_path = traversal_path.clone

          # puts "\n#{ident} [before] #{before_traversal_path.join(' > ')}, f = #{break_flag}"
          traversal_path, break_flag = try_to_find_option_tree_path(option_tree_or_value, find_id, traversal_path, ident, break_flag)
          # puts "#{ident} [after] #{traversal_path.join(' > ')}, f = #{break_flag}"

          if before_traversal_path == traversal_path
            break_flag = true
            break
          end
        end

        traversal_path.pop if !break_flag
        # puts "#{ident} [return] #{traversal_path.join(' > ')}, f = #{break_flag}"
        [traversal_path, break_flag]
      end    
    end

  end



  def option_tree_path(option_tree=self.class.to_option_tree, traversal_path=[], ident=' ')
    self.class.find_option_tree_path(option_tree, id)
  end

  def pedigree
    if option_tree = Rails.cache.read(self.class.option_tree_key)
      option_tree_path(option_tree)
    else
      _pedigree
    end
  end

  def _pedigree
    node = self
    res = [self.name]
    while node = node.parent
      res << node.name
    end
    res.reverse
  end



end