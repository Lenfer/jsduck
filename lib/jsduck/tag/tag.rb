module JsDuck::Tag
  # Base class for all builtin tags.
  class Tag
    # Defines the name of the @tag.
    # The name itself must not contain the "@" sign.
    # For example: "cfg"
    attr_reader :pattern

    # Set to true to allow the tag to occour multiple times within one
    # doc-comment.  By default a tag can only appear once and when
    # it's detected several times a warning will be generated.
    attr_reader :repeatable

    # Called by DocParser when the @tag is reached to do the parsing
    # from that point forward.  Gets passed an instance of DocScanner.
    #
    # Can return a hash or array of hashes representing the detected
    # @tag data.  Each returned hash must contain the :tagname key,
    # e.g.:
    #
    #     {:tagname => :protected, :foo => "blah"}
    #
    # All hashes with the same :tagname will later be combined
    # together and passed on to #process_doc method of this Tag class
    # that has @tagname field set to that tagname.
    #
    # The hash can also contain :doc => :multiline, in which case all
    # the documentation following this tag will get added to the :doc
    # field of the tag and will later be accessible in #process_doc
    # method.
    #
    # Also a hash with position information {:filename, :linenr} is
    # passed in.
    def parse_doc(scanner, position)
    end

    # Defines the symbol under which the tag data is stored in final
    # member/class hash.
    attr_reader :tagname

    # Gets called with the resulting class/member hash and array of
    # @tag data that was generated by #parse_doc. Also a hash with
    # position information {:filename, :linenr} is passed in.
    #
    # It can then add a new field to the class/member hash or
    # transform it in any other way desired.
    def process_doc(hash, docs, position)
    end

    # Defines a class member type and specifies a name and several
    # other settings.  For example:
    #
    #     {
    #       :name => :event,
    #       :category => :method_like,
    #       :title => "Events",
    #       :position => MEMBER_POS_EVENT,
    #       # The following are optional
    #       :toolbar_title => "Events",
    #       :subsections => [
    #         {:title => "Static events",
    #          :filter => {:static => false},
    #          :default => true},
    #         {:title => "Instance events",
    #          :filter => {:static => true}},
    #       ]
    #     }
    #
    # The category must be either :property_like or :method_like.
    #
    # Position defines the ordering of member section in final HTML
    # output.
    #
    # Title is shown at the top of each such section and also as a
    # label on Docs app toolbar button unless :toolbar_title is
    # specified.
    #
    # Subsections allows splitting the list of members to several
    # subgroups.  For example methods get split into static and
    # instance methods.
    #
    # - The :filter field defines how to filter out the members for
    #   this subcategory.  :static=>true filters out all members that
    #   have a :static field with a truthy value.  Conversely,
    #   :static=>false filters out members not having a :static field
    #   or having it with a falsy value.
    #
    # - Setting :default=>true will hide the subsection title when all
    #   the members end up in that subsection.  For example when there
    #   are only instance methods, the docs will only contain the
    #   section title "Methods", as by default one should assume all
    #   methods are instance methods if not stated otherwise.
    #
    attr_reader :member_type

    MEMBER_POS_CFG = 1
    MEMBER_POS_PROPERTY = 2
    MEMBER_POS_METHOD = 3
    MEMBER_POS_EVENT = 4
    MEMBER_POS_CSS_VAR = 5
    MEMBER_POS_CSS_MIXIN = 6

    # The text to display in member signature.  Must be a hash
    # defining the short and long versions of the signature text:
    #
    #     {:long => "something", :short => "SOM"}
    #
    # Additionally the hash can contain a :tooltip which is the text
    # to be shown when the signature bubble is hovered over in docs.
    attr_reader :signature

    # Defines the name of object property in Ext.define()
    # configuration which, when encountered, will cause the
    # #parse_ext_define method to be invoked.
    attr_reader :ext_define_pattern

    # The default value to use when Ext.define is encountered, but the
    # key in the config object itself is not found.
    # This must be a Hash defining the key and value.
    attr_reader :ext_define_default

    # Called by Ast class to parse a config in Ext.define().
    # @param {Hash} cls A simple Hash representing a class on which
    # various properties can be set.
    # @param {AstNode} ast Value of the config in Ext.define().
    def parse_ext_define(cls, ast)
    end

    # In the context of which members or classes invoke the #merge
    # method.  This can be either a single tagname like :class,
    # :method, :cfg or an array of these.
    #
    # Additionally a few special symbols can be used to register a
    # merger for a set of member types:
    #
    #   - :member - all members.
    #   - :method_like - members like :method, :event, :css_mixin
    #   - :property_like - members like :cfg, :property, :css_var
    #
    # For example to register a merger for everyting:
    #
    #     @merge_context = [:class, :member]
    #
    attr_reader :merge_context

    # Merges documentation and code hashes into the result hash.
    def merge(hash, docs, code)
    end

    # The position for outputting the HTML for the tag in final
    # documentation.
    #
    # Must be defined together with #to_html method.  Additionally the
    # #format method can be defined to perform rendering of Markdown
    # before #to_html is called.
    #
    # All builtin tags have a position that's defined by one of the
    # constants listed below.  For user-defined tags it's recommended
    # to define your position relative to one of the builtin tags.
    # For example if you want your tag to output HTML right after the
    # return value documentation, use something like:
    #
    #     @html_position = POS_RETURN + 0.1
    #
    # Later versions of JSDuck might change the actual values of these
    # constants, so don't rely on the concrete values, reference the
    # constants and add/substract fractions smaller than 1 from them.
    #
    attr_accessor :html_position

    POS_ASIDE = 1
    POS_PRIVATE = 2
    POS_DOC = 3
    POS_LOCALDOC = 4
    POS_DEFAULT = 5
    POS_SINCE = 6
    POS_DEPRECATED = 7
    POS_ENUM = 8
    POS_TEMPLATE = 9
    POS_PREVENTABLE = 10
    POS_PARAM = 11
    POS_SUBPROPERTIES = 12
    POS_RETURN = 13
    POS_THROWS = 14
    POS_OVERRIDES = 15

    # Called before #to_html to allow rendering of Markdown content.
    # For this an instance of DocFormatter is passed in, on which one
    # can call the #format method to turn Markdown into HTML.
    def format(context, formatter)
    end

    # Implement #to_html to transform tag data to HTML to be included
    # into documentation.
    #
    # It gets passed the full class/member hash. It should return an
    # HTML string to inject into document.
    def to_html(context)
    end

    # A string of CSS to add to the builtin CSS of the generated docs.
    # For example, to style a signature label:
    #
    #     @css = ".signature .mytag { color: red }"
    #
    attr_reader :css

    # Returns all descendants of JsDuck::Tag::Tag class.
    def self.descendants
      result = []
      ObjectSpace.each_object(::Class) do |cls|
        result << cls if cls < self
      end
      result
    end
  end
end
