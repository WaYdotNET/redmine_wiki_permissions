module WikiPermissions
  module MixinSearchController
    def self.included base
      base.class_eval do
        alias_method :_index, :index unless method_defined? :_index
        
        def index
          _index
          
          if @results != nil
            @results.delete_if do |result|
              result.class == WikiPage and
              not User.current.can_view? result
            end
          end
        end
        
      end      
    end
  end
end
