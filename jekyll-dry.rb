# (The MIT License)
#
# Copyright (c) 2018 Vagiz Duseev

module ContextExt
  def find_variable(key)
    variable = super(key)
    unless variable
      variable = registers[:site].fragments[key]
    end
    variable
  end
end

Jekyll::Hooks.register :site, :pre_render do |container, payload|
  Liquid::Context.prepend(ContextExt)
end

module Jekyll
  class FragmentGenerator < Generator
    TagStart = /#{Liquid::TagStart}#{Liquid::WhitespaceControl}?\s*/o
    TagEnd = /\s*#{Liquid::WhitespaceControl}?#{Liquid::TagEnd}/o
    FragmentSubPattern = /#{TagStart}(?i:(end)?frag)\s*(.*?)#{TagEnd}\s*/om
    FullFragmentPattern = %r/
      #{TagStart}(?i:frag)\s*(?<id>.*?)#{TagEnd}
      (?<body>.*)
      #{TagStart}(?i:endfrag)\s*\k<id>#{TagEnd}
    /xom

    def generate(site)
      # Initialize hash map that will store the fragments for rendering
      class << site
        attr_accessor :fragments
      end
      site.fragments = Hash.new

      # Parse fragments on pages
      site.pages.each do |page|
        fragments = parse_page(page.content)

        site.fragments.merge!(fragments) do |key, old_val, new_val|
          # This section is invoked every time there is a duplicate key
          # in site.fragments and parsed fragments
          raise Liquid::SyntaxError.new(
            "Duplicate fragment #{key} on page #{page.url}",
            original_fragment: old_val,
            duplicate_fragment: new_val
          )
        end
      end
    end

    def parse_page(content)
      fragments = Hash.new

      pos = 0
      while m = FullFragmentPattern.match(content, pos)
        body = clean_fragment(m[:body])
        fragments.store(m[:id], body)
        puts("fragment #{m[:id]}:", body)
        pos = m.begin(:id)
      end
      fragments
    end

    def clean_fragment(body)
      pattern = /\s*#{FragmentSubPattern}\s*/om
      clean_body = body.gsub(FragmentSubPattern, "")
      clean_body.lstrip!
      clean_body.rstrip!
    end
  end

  class FragmentBlockBody < Liquid::BlockBody
    def initialize
      super
    end

    def whitespace_handler(token, parse_context)
      return unless token =~ Jekyll::FragmentGenerator::FragmentSubPattern
      previous_token = @nodelist.last
      if previous_token.is_a? String
        # previous_token.rstrip!
      end
      parse_context.trim_whitespace = true
    end
  end

  class FragmentBlock < Liquid::Block
    def initialize(tag_name, markup, options)
      super
    end

    def parse(tokens)
      @body = FragmentBlockBody.new
      while parse_body(@body, tokens)
      end
    end
  end

  class Fragment < FragmentBlock
    def initialize(tag_name, markup, options)
      super
      @fragment_id, _ = markup.strip.split(%r!\s+!, 2)
    end

    def render(context)
      output = super
      #context[@fragment_id] = output
      #context.resource_limits.assign_score += output.length
      output
    end
  end
end

Liquid::Template.register_tag('frag', Jekyll::Fragment)
