module Sergi #:nocdoc:
  module Acts #:nocdoc:
    module Messageable #:nodoc
      class Mailbox
        #this is used to filter mail by mailbox type, use the [] method rather than setting this directly.
        attr_accessor :type
        #the member/owner of this mailbox, set when initialized.
        attr_reader :member
        #creates a new Mailbox instance with the given member and optional type.
        def initialize(member, type = :all)
          @member = member
          @type = type
        end
        #sets the mailbox type to the symbol corresponding to the given val.
        def type=(val)
          @type = val.to_sym
        end
        #returns a count of mail messages filtered by type and filter, if set.
        #
        #*this performs an actual sql count rather than selecting all mail and then gettin a length on the array... not a big deal but this could be something that is checked often to notify the member when they receive a new mail.
        #
        #====params:
        #filter:: filters the count by the 'read' attribute.
        #* :all - count of both read and unread mail.
        #* :read - count of read mail.
        #* :unread - count of unread mail.
        #options:: see mail for acceptable options.
        #
        #====returns:
        #number of mail messages
        #
        #====example:
        #   phil = Member.find(3123)
        #
        #   #get number of unread mail messages in phil's inbox
        #   phil.mailbox[:inbox].mail_count(:unread)
        #
        def mail_count(filter = :all, options = {})
          default_options = {:conditions => ["mail.member_id = ?", @member.id]}
          add_mailbox_condition!(default_options, @type)
          add_conditions!(default_options, "mail.read = ?", filter == :read) unless filter == :all
          return count_mail(default_options, options)
        end
        #returns an array of all Mail for the member filtered by type, if set. 
        #
        #====params:
        #options:: all valid find options are accepted as well as an additional conversation option.
        #* :conversation - Conversation object to filter mail only belonging to this conversation.
        #* :conditions - same as find conditions however the array version of conditions will not work, i.e., :conditions => ['mail.read = ?', false] will not work here.
        #* all other find options will work as expected.
        # 
        #====returns:
        #array of Mail.
        #
        #====example:
        #   phil = member.find(3123)
        #
        #   #get all mail messages belonging to phil
        #   phil.mailbox.mail
        #
        #   #get all mail messages in phil's inbox associated with conversation 23
        #   phil.mailbox[:inbox].mail(:conversation => Conversation.find(23)) 
        #
        #   #get all unread mail messages belonging to phil associated with conversation 23
        #   phil.mailbox.mail(:conversation => Conversation.find(23), :conditions => 'mail.read = false')
        #
        def mail(options = {})
          default_options = {}
          add_mailbox_condition!(default_options, @type)
          return get_mail(default_options, options)
        end
        #returns an array of unread Mail for the member filtered by type, if set. 
        #
        #====params:
        #options:: see mail for acceptable options.
        # 
        #====returns:
        #array of Mail.
        #
        #====example:
        #   phil = Member.find(3123)
        #
        #   #get all unread mail in phil's inbox
        #   phil.mailbox[:inbox].unread_mail
        #
        def unread_mail(options = {})
          default_options = {:conditions => ["mail.read = ?", false]}
          add_mailbox_condition!(default_options, @type)
          return get_mail(default_options, options)
        end
        #returns an array of read Mail for the member filtered by type, if set. 
        #
        #====params:
        #options:: see mail for acceptable options.
        # 
        #====returns:
        #array of Mail.
        #
        #====example:
        #   phil = member.find(3123)
        #
        #   #get all read mail in phil's inbox
        #   phil.mailbox[:inbox].read_mail
        #
        def read_mail(options = {})
          default_options = {:conditions => ["mail.read = ?", true]}
          add_mailbox_condition!(default_options, @type)
          return get_mail(default_options, options)
        end
        #returns an array of the latest Mail message for each conversation the member is involved in filtered by type, if set. 
        #
        #*possible use for this would be an inbox view of your mail so you can easily see the status of all the convos your involved in.
        #
        #====params:
        #options:: see mail for acceptable options.
        # 
        #====returns:
        #array of Mail.
        #
        #====example:
        #   phil = member.find(3123)
        #
        #   #get a list of the latest received mail for each conversation
        #   phil.mailbox[:inbox].latest_mail
        #
        def latest_mail(options = {})
          return only_latest(mail(options))
        end
        #adds a mail message to the member's mailbox specified by type.
        #
        #*this is used when sending a new message, all the recipients get a mail added to their inbox and the sender gets a mail in their sentbox.
        #
        #====params:
        #msg:: 
        #     Message object from which a new mail is created from.
        # 
        #====returns:
        #new Mail.
        #
        def add(msg)
          attributes = {:message => msg, :conversation => msg.conversation}
          attributes[:mailbox] = @type.to_s unless @type == :all
          attributes[:read] = msg.sender.id == @member.id
          mail_msg = Mail.new(attributes)
          @member.mail << mail_msg
          return mail_msg
        end
        #marks all the mail messages matched by the options and type as read.
        #
        #====params:
        #options:: see mail for acceptable options.
        # 
        #====returns:
        #array of Mail.
        #
        #====example:
        #   phil = member.find(3123)
        #
        #   #mark all inbox messages as read
        #   phil.mailbox[:inbox].mark_as_read()
        #
        def mark_as_read(options = {})
          default_options = {}
          add_mailbox_condition!(default_options, @type)
          return update_mail("mail.read = true", default_options, options)
        end
        #marks all the mail messages matched by the options and type as unread, except for sent messages.
        #
        #====params:
        #options:: see mail for acceptable options.
        # 
        #====returns:
        #array of Mail.
        #
        #====example:
        #   phil = member.find(3123)
        #
        #   #mark all inbox messages as unread
        #   phil.mailbox[:inbox].mark_as_unread()
        #
        def mark_as_unread(options = {})
          default_options = {:conditions => ["mail.mailbox != ?",@member.mailbox_types[:sent].to_s]}
          add_mailbox_condition!(default_options, @type)
          return update_mail("mail.read = false", default_options, options)
        end
        #moves all mail matched by the options to the given mailbox. sent messages stay in the sentbox.
        #
        #====params:
        #mailbox:: the mailbox_type to move the mail messages to. (ex. :inbox, :trash)
        #options:: see mail for acceptable options.
        # 
        def move_to(mailbox, options = {})
          mailbox = mailbox.to_sym
          trash = mailbox == @member.mailbox_types[:deleted].to_sym
          default_options = {}
          add_mailbox_condition!(default_options, @type)
          if(!trash)
            #conditional update because sentmail is always sentmail - I believe case if the most widely supported conditional, mysql also has an if which would work as well but i think mysql is the only one to support it
            return update_mail("mail.trashed = false, mail.mailbox = 
            CASE mail.mailbox
              WHEN '#{@member.mailbox_types[:sent].to_s}' THEN mail.mailbox
              ELSE '#{mailbox.to_s}'
            END", default_options, options)
          end
          return update_mail("mail.trashed = true", default_options, options)
        end
        #permanantly deletes all the mail messages matched by the options. Use move_to(:trash) instead if you want to send to member's trash without deleting.
        #
        #====params:
        #options:: see mail for acceptable options.
        # 
        def delete(options = {})
          default_options = {:conditions => ["mail.member_id = ?", @member.id]}
          add_mailbox_condition!(default_options, @type)
          return delete_mail(default_options, options)
        end
        #alias for add
        def <<(msg)
          return self.add(msg)
        end
        #deletes all messages that have been trashed and match the options if passed.
        #
        #====params:
        #options:: see mail for acceptable options.
        # 
        def empty_trash(options = {})
          default_options = {:conditions => ["mail.member_id = ? AND mail.trashed = ?", @member.id, true]}
          add_mailbox_condition!(default_options, @type)
          return delete_mail(default_options, options)
        end
        #return true if the member is involved in the given conversation.
        def has_conversation?(conversation)
          return mail_count(:all, :conversation => conversation) != 0
        end
        #sets the mailbox type and returns itself.
        #
        #====params:
        #mailbox_type::
        #     type of mailbox to filter mail by, this can be anything, but the three most likely values for this will be the received, sent, and trash values set within the acts_as_messageable method.
        # 
        #====returns:
        #self
        #
        #====example:
        #   phil = member.find(3123)
        #
        #   #all mails in the member's inbox
        #   phil.mailbox[:inbox].mail
        #
        def [](mailbox_type)
          self.type = mailbox_type
          return self
        end
        private
        def get_mail(default_options, options)
          build_options(default_options, options) unless options.empty?
          return @member.mail.find(:all, default_options)
        end
        def update_mail(updates, default_options, options)
          build_options(default_options, options) unless options.empty?
          return @member.mail.update_all(updates, default_options[:conditions])
        end
        def delete_mail(default_options, options)
          build_options(default_options, options) unless options.empty?
          return Mail.delete_all(default_options[:conditions])
        end
        def count_mail(default_options, options)
          build_options(default_options, options) unless options.empty?
          return Mail.count(:all, default_options)
        end
        def build_options(default_options, options)
          add_conversation_condition!(default_options, options[:conversation]) unless options[:conversation].nil?
          options.delete(:conversation)
          add_conditions!(default_options, options[:conditions]) unless options[:conditions].nil?
          options.delete(:conditions)
          default_options.merge!(options)
        end
        def only_latest(mail)
          convos = []
          latest = []
          mail.each do |m|
            next if(convos.include?(m.conversation_id))
            convos << m.conversation_id
            latest << m
          end
          return latest
        end
        def add_mailbox_condition!(options, mailbox_type)
          return if mailbox_type == :all
          return add_conditions!(options, "mail.mailbox = ? AND mail.trashed = ?", mailbox_type.to_s, false) unless mailbox_type == @member.mailbox_types[:deleted]
          return add_conditions!(options, "mail.trashed = ?", true)
        end
        def add_conversation_condition!(options, conversation)
          options.merge!({:order => 'created_at ASC'})
          if(conversation.is_a?(Array))
            conversation.map! {|c| c.is_a?(Integer) ? c : c.id}
          else
            conversation = conversation.is_a?(Integer) ? [conversation] : [conversation.id]
          end
          return add_conditions!(options, "conversation_id IN (?)", conversation)
        end
        def add_conditions!(options, conditions, *values)
          return nil unless options.is_a?(Hash)
          if(options[:conditions].nil?)
            options[:conditions] = values.length == 0 ? conditions : [conditions]
          elsif(options[:conditions].is_a?(Array))
            options[:conditions][0] = "(#{options[:conditions][0]}) AND (#{conditions})"
          else
            options[:conditions] = "(#{options[:conditions]}) AND (#{conditions})"
          end
          values.each do |val|
              options[:conditions].push(val)
          end
          return options
        end
      end
    end
  end
end