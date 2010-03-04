require 'mailbox'

module Sergi #:nocdoc:
  module Acts #:nocdoc:
    module Messageable #:nocdoc:
      
      def self.included(mod)
        mod.extend(ClassMethods)
      end
  
      # declare the class level helper methods which
      # will load the relevant instance methods
      # defined below when invoked
      module ClassMethods
        #enables a class to send and receive messages to members of the same class - currently assumes the model is of class type 'User', 
        #some modifications to the migrations and model classes will need to be made to use a model of different type.
        #
        #====options:
        #* :received - the mailbox type to store received messages (defaults to :inbox)
        #
        #* :sent - the mailbox type to store sent messages (defaults to :sentbox)
        #
        #* :deleted - the mailbox type to store deleted messages (defaults to :trash)
        #
        #====example:
        #   acts_as_messageable :received => :in, :sent => :sent, :deleted => :garbage
        def acts_as_messageable(options = {})
          cattr_accessor :mailbox_types
          has_many :mail, :order => 'created_at DESC', :dependent => :delete_all
          
          self.mailbox_types = {
            :received => :inbox,
            :sent => :sentbox,
            :deleted => :trash
          }.merge(options)
          
          include Sergi::Acts::Messageable::InstanceMethods
          #extend Juixe::Acts::Commentable::SingletonMethods
        end
      end
      
      #Adds class methods
      #module SingletonMethods
      #end

      # Adds instance methods.
      module InstanceMethods
        #returns an instance of class type Mailbox - this object essentially wraps the user's mail messages and provides a clean interface for accessing them. 
        #see Mailbox for more details.
        #
        #====example:
        #   phil = User.find(3123)
        #   phil.mailbox[:inbox].unread_mail      #returns all unread mail in your inbox
        #   phil.mailbox[:sentbox].mail         #returns all sent mail messages
        #  
        def mailbox()
          @mailbox = Mailbox.new(self) if @mailbox.nil?
          @mailbox.type = :all
          return @mailbox
        end
        #creates new Message and Conversation objects from the given parameters and delivers Mail to each of the recipients' inbox.
        #
        #====params:
        #recipients::
        #     a single user object or array of users to deliver the message to.
        #msg_body::
        #     the body of the message.
        #subject::
        #     the subject of the message, defaults to empty string if not provided.
        #====returns:
        #the sent Mail.
        #
        #====example:
        #   phil = User.find(3123)
        #   todd = User.find(4141)
        #   phil.send_message(todd, 'whats up for tonight?', 'hey guy')      #sends a Mail message to todd's inbox, and a Mail message to phil's sentbox
        #  
        def send_message(recipients, msg_body, subject = '')
          convo = Conversation.create({:subject => subject})
          message = Message.create({:sender => self, :conversation => convo,  :body => msg_body, :subject => subject})
          message.recipients = recipients.is_a?(Array) ? recipients : [recipients]
          message.deliver(self.mailbox_types[:received])
          return mailbox[:sentbox] << message
        end
        #creates a new Message associated with the given conversation and delivers the reply to each of the given recipients.
        #
        #*explicitly calling this method is rare unless you are replying to a subset of the users involved in the conversation or 
        #if you are including someone that is not currently in the conversation. 
        #reply_to_sender, reply_to_all, and reply_to_conversation will suffice in most cases.
        #
        #====params:
        #conversation::
        #     the Conversation object that the mail you are responding to belongs.
        #recipients::
        #     a single User object or array of Users to deliver the reply message to.
        #reply_body::
        #     the body of the reply message.
        #subject::
        #     the subject of the message, defaults to 'RE: [original subject]' if one isnt given.
        #====returns:
        #the sent Mail.
        #
        def reply(conversation, recipients, reply_body, subject = nil)
          return nil if(reply_body.blank?)
          subject = subject || "RE: #{conversation.subject}"
          response = Message.create({:sender => self, :conversation => conversation, :body => reply_body, :subject => subject})
          response.recipients = recipients.is_a?(Array) ? recipients : [recipients]
          response.deliver(self.mailbox_types[:received])
          return mailbox[self.mailbox_types[:sent]] << response
        end
        #sends a Mail to the sender of the given mail message.
        #
        #====params:
        #mail::
        #     the Mail object that you are replying to.
        #reply_body::
        #     the body of the reply message.
        #subject::
        #     the subject of the message, defaults to 'RE: [original subject]' if one isnt given.
        #====returns:
        #the sent Mail.
        #
        def reply_to_sender(mail, reply_body, subject = nil)
          return reply(mail.conversation, mail.message.sender, reply_body, subject)
        end
        #sends a Mail to all of the recipients of the given mail message (excluding yourself).
        #
        #====params:
        #mail::
        #     the Mail object that you are replying to.
        #reply_body::
        #     the body of the reply message.
        #subject::
        #     the subject of the message, defaults to 'RE: [original subject]' if one isnt given.
        #====returns:
        #the sent Mail.
        #
        def reply_to_all(mail, reply_body, subject = nil)
          msg = mail.message
          recipients = msg.recipients.clone()
          if(msg.sender != self)
            recipients.delete(self)
            if(!recipients.include?(msg.sender))
              recipients << msg.sender
            end
          end
          return reply(mail.conversation, recipients, reply_body, subject)
        end
        #sends a Mail to all users involved in the given conversation (excluding yourself).
        #
        #*this may have undesired effects if users have been added to the conversation after it has begun.
        #
        #====params:
        #conversation::
        #     the Conversation object that the mail you are responding to belongs.
        #reply_body::
        #     the body of the reply message.
        #subject::
        #     the subject of the message, defaults to 'RE: [original subject]' if one isnt given.
        #====returns:
        #the sent Mail.
        #
        def reply_to_conversation(conversation, reply_body, subject = nil)
          #move conversation to inbox if it is currently in the trash - doesnt make much sense replying to a trashed convo.
          if((mailbox[self.mailbox_types[:deleted]].has_conversation?(conversation)))
            mailbox.move_to(self.mailbox_types[:received], :conversation => conversation)
          end
          #remove self from recipients unless you are the originator of the convo
          recipients = conversation.original_message.recipients.clone()
          if(conversation.originator != self)
            recipients.delete(self)
            if(!recipients.include?(conversation.originator))
              recipients << conversation.originator
            end
          end
          return reply(conversation,recipients, reply_body, subject)
        end
        #returns the mail given as the parameter, marked as read.
        def read_mail(mail)
          return mail.mark_as_read()
        end
        #returns an array of the user's Mail associated with the given conversation. 
        #All mail is marked as read but the returning array is built before this so you can see which messages were unread when viewing the conversation.
        #
        #This returns deleted/trashed messages as well for the purpose of reading trashed convos, to disable this send the option ':conditions => "mail.trashed != true"'
        #
        #====params:
        #conversation::
        #     the Conversation object that you want to read.
        #options::
        #     any options to filter the conversation, these are used as find options so all valid options for find will work.
        #
        #====returns:
        #array of Mail belonging to the given conversation.
        #
        def read_conversation(conversation, options = {})
          convo_mail = self.mailbox.mail(options.merge(:conversation => conversation))
          self.mailbox.mark_as_read(:conversation => conversation)
          return convo_mail
        end
      end

    end
  end
end

# reopen ActiveRecord and include all the above to make
# them available to all our models if they want it

ActiveRecord::Base.class_eval do
  include Sergi::Acts::Messageable
end