module WikiPermissions  
  module MixinWikiController
    
    def self.included base
      base.send(:include, InstanceMethods)
      
      base.class_eval do        
        helper_method :include_module_wiki_permissions?        
      end
    end
    
    
    module InstanceMethods
      
      def page_data_logic
        page_title = params[:page]
        @page = @wiki.find_or_new_page(page_title)
        if @page.new_record?
          if User.current.allowed_to?(:edit_wiki_pages, @project)
            edit
            render :action => 'edit'
          else
            render_404
          end
          return
        end
        if params[:version] && !User.current.allowed_to?(:view_wiki_edits, @project)
          # Redirects user to the current version if he's not allowed to view previous versions
          redirect_to :version => nil
          return
        end
        @content = @page.content_for_version(params[:version])
        if params[:export] == 'html'
          export = render_to_string :action => 'export', :layout => false
          send_data(export, :type => 'text/html', :filename => "#{@page.title}.html")
          return
        elsif params[:export] == 'txt'
          send_data(@content.text, :type => 'text/plain', :filename => "#{@page.title}.txt")
          return
        end
        @editable = editable?
        render :template => 'wiki/show'
      end
      
      def authorize ctrl = params[:controller], action = params[:action]
        allowed = User.current.allowed_to?({ :controller => ctrl, :action => action }, @project, { :params => params })
        allowed ? true : deny_access
      end
      
      def permissions
        find_existing_page
        @wiki_page_user_permissions = WikiPageUserPermission.all :conditions => { :wiki_page_id => @page.id }
        render :template => 'wiki/edit_permissions'
      end
      
      def create_wiki_page_user_permissions
        @wiki_page_user_permission = WikiPageUserPermission.new(params[:wiki_page_user_permission])
        if @wiki_page_user_permission.save
          redirect_to :action => 'permissions'
        else
          render :action => 'new'
        end
      end
      
      def update_wiki_page_user_permissions
        params[:wiki_page_user_permission].each_pair do |index, level|
          permission = WikiPageUserPermission.find index.to_i
          permission.level = level.to_i
          permission.save
        end
        redirect_to :back
      end
      
      def destroy_wiki_page_user_permissions
        WikiPageUserPermission.find(params[:permission_id]).destroy
        redirect_to :back
      end
      
      def include_module_wiki_permissions?
       (@page.project.enabled_modules.detect { |enabled_module| enabled_module.name == 'wiki_permissions' }) != nil
      end
      
    end
    
  end
end