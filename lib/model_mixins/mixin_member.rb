module WikiPermissions  
   
  module MixinMember
    def self.included base
      base.class_eval do
        has_many :wiki_page_user_permissions
      end
    end
  end
end
