module Plugins
  module FlexxPluginCrm
    class UserDecorator < Draper::Decorator
      delegate_all

      # Define presentation-specific methods here. Helpers are accessed through
      # `helpers` (aka `h`). You can override attributes, for example:
      #
      def avatar_presentation(**args)
        cls = 'avatar'
        cls += ' ' + args[:class] if args[:class]

        style = "background-image:url(#{object.avatar && object.avatar.url})"
        style += '; ' + args[:style] if args[:style]

        model = object.is_a?(CamaleonCms::User) ? 'user' : 'contact'
        data = { "#{model}-avatar": object.initials }
        data.merge! args[:data] if args[:data]

        h.content_tag :span, class: cls, style: style, data: data do
          object.avatar.nil? ? object.initials : ''
        end
      end
    end
  end
end
