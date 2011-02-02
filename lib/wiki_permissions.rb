require 'controller_mixins/mixin_search_controller'
require 'controller_mixins/mixin_wiki_controller'

require 'model_mixins/mixin_member'
require 'model_mixins/mixin_user'
require 'model_mixins/mixin_wiki_page'

require 'dispatcher'
  Dispatcher.to_prepare do 
    begin
      require_dependency 'application'
    rescue LoadError
      require_dependency 'application_controller'
    end

  Member.send :include, WikiPermissions::MixinMember
  WikiPage.send :include, WikiPermissions::MixinWikiPage  
  WikiController.send :include, WikiPermissions::MixinWikiController
  SearchController.send :include, WikiPermissions::MixinSearchController
  User.send :include, WikiPermissions::MixinUser
end