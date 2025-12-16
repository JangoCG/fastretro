class ButtonComponent < ApplicationComponent
  BASE_CLASSES = "group relative inline-flex items-center justify-center font-bold uppercase tracking-widest transition-all duration-200 hover:-translate-y-0.5 active:translate-y-0 focus:outline-none disabled:opacity-50 disabled:cursor-not-allowed border-[2px] rounded-0"

  VARIANTS = {
    primary: "bg-zinc-900 border-zinc-900 text-[#F8F5EC] hover:bg-white hover:text-zinc-900 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:shadow-none active:shadow-none",
    secondary: "bg-white border-zinc-900 text-zinc-900 hover:bg-zinc-100 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:shadow-none active:shadow-none",
    danger: "bg-red-600 border-red-600 text-white hover:bg-white hover:text-red-600 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:shadow-none active:shadow-none",
    success: "bg-green-600 border-green-600 text-white hover:bg-white hover:text-green-600 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:shadow-none active:shadow-none",
    ghost: "bg-transparent border-transparent text-zinc-500 hover:text-zinc-900 hover:bg-zinc-100"
  }.freeze

  SIZES = {
    sm: "py-1.5 px-4 text-sm",
    md: "",
    lg: "py-3 px-8 text-lg"
  }.freeze

  ICON_SIZES = {
    sm: "text-base",
    md: "text-lg",
    lg: "text-xl"
  }.freeze

  def initialize(
    variant: :primary,
    size: :md,
    tag: :button,
    href: nil,
    icon: nil,
    icon_position: :left,
    disabled: false,
    **options
  )
    @variant = variant
    @size = size
    @tag = href ? :a : tag
    @href = href
    @icon = icon
    @icon_position = icon_position
    @disabled = disabled
    @options = options
  end

  def call
    content_tag(@tag, tag_options) do
      safe_join([
        icon_tag_left,
        content,
        icon_tag_right
      ].compact)
    end
  end

  private

  def tag_options
    opts = {
      class: class_names(
        BASE_CLASSES,
        VARIANTS[@variant],
        SIZES[@size],
        @options.delete(:class)
      ),
      disabled: @disabled || nil,
      **@options
    }

    opts[:href] = @href if @tag == :a
    opts[:type] = "button" if @tag == :button && !@options[:type]
    opts
  end

  def icon_tag_left
    return unless @icon && @icon_position == :left
    helpers.icon_tag(@icon, class: ICON_SIZES[@size])
  end

  def icon_tag_right
    return unless @icon && @icon_position == :right
    helpers.icon_tag(@icon, class: ICON_SIZES[@size])
  end
end
