class IconButtonComponent < ApplicationComponent
  BASE_CLASSES = "group relative flex items-center justify-center transition-all duration-200 hover:-translate-y-0.5 active:translate-y-0 focus:outline-none disabled:opacity-50 disabled:cursor-not-allowed border-[2px] rounded-0"

  VARIANTS = {
    primary: "bg-zinc-900 border-zinc-900 text-[#F8F5EC] hover:bg-white hover:text-zinc-900 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:shadow-none active:shadow-none",
    secondary: "bg-white border-zinc-900 text-zinc-900 hover:bg-zinc-100 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:shadow-none active:shadow-none",
    danger: "bg-white border-transparent text-red-600 hover:border-red-600 hover:bg-red-50",
    ghost: "bg-transparent border-transparent text-zinc-500 hover:text-zinc-900 hover:bg-zinc-100"
  }.freeze

  SIZES = {
    sm: "w-8 h-8",
    md: "w-10 h-10",
    lg: "w-12 h-12"
  }.freeze

  ICON_SIZES = {
    sm: "text-lg",
    md: "text-xl",
    lg: "text-2xl"
  }.freeze

  def initialize(
    icon:,
    variant: :primary,
    size: :md,
    tag: :button,
    href: nil,
    label: nil,
    disabled: false,
    **options
  )
    @icon = icon
    @variant = variant
    @size = size
    @tag = href ? :a : tag
    @href = href
    @label = label
    @disabled = disabled
    @options = options
  end

  def call
    content_tag(@tag, tag_options) do
      safe_join([
        sr_only_label,
        helpers.icon_tag(@icon, class: ICON_SIZES[@size])
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
      "aria-label": @label,
      **@options
    }

    opts[:href] = @href if @tag == :a
    opts[:type] = "button" if @tag == :button && !@options[:type]
    opts
  end

  def sr_only_label
    return unless @label
    content_tag(:span, @label, class: "sr-only")
  end
end
