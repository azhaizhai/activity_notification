module ActivityNotification
  # Provides a shortcut from views to the rendering method.
  # Module extending ActionView::Base and adding `render_notification` helper.
  module ViewHelpers
    # View helper for rendering an notification, calls {Notification#render} internally.
    # @see Notification#render
    #
    # @param [Notification, Array] Array or single instance of notifications to render
    # @param [Hash] options Options for rendering notifications
    # @option options [String, Symbol] :target       (nil)                     Target type name to find template or i18n text
    # @option options [String]         :partial      ("activity_notification/notifications/#{target}", controller.target_view_path, 'activity_notification/notifications/default') Partial template name
    # @option options [String]         :partial_root (self.key.gsub('.', '/')) Root path of partial template
    # @option options [String]         :layout       (nil)                     Layout template name
    # @option options [String]         :layout_root  ('layouts')               Root path of layout template
    # @option options [String]         :fallback     (nil)                     Fallback template to use when MissingTemplate is raised. Set :text to use i18n text as fallback.
    # @return [String] Rendered view or text as string
    def render_notification(notifications, options = {})
      if notifications.is_a? ActivityNotification::Notification
        notifications.render self, options
      elsif notifications.respond_to?(:map)
        return nil if notifications.empty?
        notifications.map {|notification| notification.render self, options.dup }.join.html_safe
      end
    end
    alias_method :render_notifications, :render_notification

    # View helper for rendering on notifications of the target to embedded partial template.
    # It calls {Notification#render} to prepare view as {content_for :index_content}
    # and render partial index calling {yield :index_content} internally.
    # For example, this method can be used for notification index as dropdown in common header.
    # @todo Show examples
    #
    # @param [Object] target Target instance of the rendering notifications
    # @param [Hash] options Options for rendering notifications
    # @option options [String, Symbol] :target               (nil)       Target type name to find template or i18n text
    # @option options [String]         :partial_root         ("activity_notification/notifications/#{target.to_resources_name}", 'activity_notification/notifications/default') Root path of partial template
    # @option options [String]         :notification_partial ("activity_notification/notifications/#{target.to_resources_name}", controller.target_view_path, 'activity_notification/notifications/default') Partial template name of the notification index content
    # @option options [String]         :layout_root          ('layouts') Root path of layout template
    # @option options [String]         :notification_layout  (nil)       Layout template name of the notification index content
    # @option options [String]         :fallback             (nil)       Fallback template to use when MissingTemplate is raised. Set :text to use i18n text as fallback.
    # @option options [String]         :partial              ('index')   Partial template name of the partial index
    # @option options [String]         :layout               (nil)       Layout template name of the partial index
    # @return [String] Rendered view or text as string
    def render_notification_of target, options = {}
      return unless target.is_a? ActivityNotification::Target

      # Prepare content for notifications index
      notification_options = options.merge target: target.to_resources_name, 
                               partial: options[:notification_partial], layout: options[:notification_layout]
      notification_index =
        case options[:index_content]
        when :simple then target.notification_index
        when :none   then target.notifications.none
        else              target.notification_index_with_attributes
        end
      prepare_content_for(target, notification_index, notification_options)

      # Render partial index
      render_partial_index(target, options)
    end
    alias_method :render_notifications_of, :render_notification_of

    # Returns notification_path for the notification
    #
    # @param [Notification] notification Notification instance
    # @param [Hash] params Request parameters
    # @return [String] notification_path for the notification
    # @todo Is there any other better implementation?
    # @todo We must handle devise namespace
    def notification_path_for(notification, params = {})
      send("#{notification.target.to_resource_name}_notification_path", notification.target, notification, params)
    end

    # Returns move_notification_path for the target of specified notification
    #
    # @param [Notification] notification Notification instance
    # @param [Hash] params Request parameters
    # @return [String] move_notification_path for the target
    # @todo Is there any other better implementation?
    # @todo We must handle devise namespace
    def move_notification_path_for(notification, params = {})
      send("move_#{notification.target.to_resource_name}_notification_path", notification.target, notification, params)
    end

    # Returns open_notification_path for the target of specified notification
    #
    # @param [Notification] notification Notification instance
    # @param [Hash] params Request parameters
    # @return [String] open_notification_path for the target
    # @todo Is there any other better implementation?
    # @todo We must handle devise namespace
    def open_notification_path_for(notification, params = {})
      send("open_#{notification.target.to_resource_name}_notification_path", notification.target, notification, params)
    end

    # Returns open_all_notifications_path for the target of specified notification
    #
    # @param [Notification] notification Notification instance
    # @param [Hash] params Request parameters
    # @return [String] open_all_notifications_path for the target
    # @todo Is there any other better implementation?
    # @todo We must handle devise namespace
    def open_all_notifications_path_for(target, params = {})
      send("open_all_#{target.to_resource_name}_notifications_path", target, params)
    end

    # Returns notification_url for the target of specified notification
    #
    # @param [Notification] notification Notification instance
    # @param [Hash] params Request parameters
    # @return [String] notification_url for the target
    # @todo Is there any other better implementation?
    # @todo We must handle devise namespace
    def notification_url_for(notification, params = {})
      send("#{notification.target.to_resource_name}_notification_url", notification.target, notification, params)
    end

    # Returns move_notification_url for the target of specified notification
    #
    # @param [Notification] notification Notification instance
    # @param [Hash] params Request parameters
    # @return [String] move_notification_url for the target
    # @todo Is there any other better implementation?
    # @todo We must handle devise namespace
    def move_notification_url_for(notification, params = {})
      send("move_#{notification.target.to_resource_name}_notification_url", notification.target, notification, params)
    end

    # Returns open_notification_url for the target of specified notification
    #
    # @param [Notification] notification Notification instance
    # @param [Hash] params Request parameters
    # @return [String] open_notification_url for the target
    # @todo Is there any other better implementation?
    # @todo We must handle devise namespace
    def open_notification_url_for(notification, params = {})
      send("open_#{notification.target.to_resource_name}_notification_url", notification.target, notification, params)
    end

    # Returns open_all_notifications_url for the target of specified notification
    #
    # @param [Notification] notification Notification instance
    # @param [Hash] params Request parameters
    # @return [String] open_all_notifications_url for the target
    # @todo Is there any other better implementation?
    # @todo We must handle devise namespace
    def open_all_notifications_url_for(target, params = {})
      send("open_all_#{target.to_resource_name}_notifications_url", target, params)
    end


    private

      def prepare_content_for(target, notification_index, params)
        content_for :notification_index do
          @target = target
          begin
            render_notification notification_index, params
          rescue ActionView::MissingTemplate
            params.delete(:target)
            render_notification notification_index, params
          end
        end
      end

      def render_partial_index(target, params)
        index_path = params.delete(:partial)
        partial    = partial_index_path(target, index_path, params[:partial_root])
        layout     = layout_path(params.delete(:layout), params[:layout_root])
        locals     = (params[:locals] || {}).merge(target: target)
        begin
          render params.merge(partial: partial, layout: layout, locals: locals)
        rescue ActionView::MissingTemplate
          partial = partial_index_path(target, index_path, 'activity_notification/notifications/default')
          render params.merge(partial: partial, layout: layout, locals: locals)
        end
      end

      def partial_index_path(target, path = nil, root = nil)
        path ||= 'index'
        root ||= "activity_notification/notifications/#{target.to_resources_name}"
        select_path(path, root)
      end

      def layout_path(path = nil, root = nil)
        path.nil? and return
        root ||= 'layouts'
        select_path(path, root)
      end

      def select_path(path, root)
        [root, path].map(&:to_s).join('/')
      end

  end

  ActionView::Base.class_eval { include ViewHelpers }
end