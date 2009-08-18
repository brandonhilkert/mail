# encoding: utf-8
require File.dirname(__FILE__) + '/../spec_helper'

require 'mail'

describe "Test emails" do
  
  describe "from RFC2822" do

    # From RFC 2822:
    # This could be called a canonical message.  It has a single author,
    # John Doe, a single recipient, Mary Smith, a subject, the date, a
    # message identifier, and a textual message in the body.
    it "should handle the basic test email" do
      email =<<EMAILEND
From: John Doe <jdoe@machine.example>
To: Mary Smith <mary@example.net>
Subject: Saying Hello
Date: Fri, 21 Nov 1997 09:55:06 -0600
Message-ID: <1234@local.machine.example>

This is a message just to say hello.
So, "Hello".
EMAILEND
      mail = Mail::Message.new(email)
      mail.from.formatted.should == ['John Doe <jdoe@machine.example>']
      mail.to.formatted.should == ['Mary Smith <mary@example.net>']
      mail.message_id.to_s.should == '<1234@local.machine.example>'
      mail.date.date_time.should == ::DateTime.parse('21 Nov 1997 09:55:06 -0600')
      mail.subject.to_s.should == 'Saying Hello'
    end

    # From RFC 2822:
    # If John's secretary Michael actually sent the message, though John
    # was the author and replies to this message should go back to him, the
    # sender field would be used:
    it "should handle the sender test email" do
      email =<<EMAILEND
From: John Doe <jdoe@machine.example>
Sender: Michael Jones <mjones@machine.example>
To: Mary Smith <mary@example.net>
Subject: Saying Hello
Date: Fri, 21 Nov 1997 09:55:06 -0600
Message-ID: <1234@local.machine.example>

This is a message just to say hello.
So, "Hello".
EMAILEND
      mail = Mail::Message.new(email)
      mail.from.formatted.should == ['John Doe <jdoe@machine.example>']
      mail.sender.formatted.should == ['Michael Jones <mjones@machine.example>']
      mail.to.formatted.should == ['Mary Smith <mary@example.net>']
      mail.message_id.to_s.should == '<1234@local.machine.example>'
      mail.date.date_time.should == ::DateTime.parse('21 Nov 1997 09:55:06 -0600')
      mail.subject.to_s.should == 'Saying Hello'
    end

    # From RFC 2822:
    # This message includes multiple addresses in the destination fields
    # and also uses several different forms of addresses.
    #
    # Note that the display names for Joe Q. Public and Giant; "Big" Box
    # needed to be enclosed in double-quotes because the former contains
    # the period and the latter contains both semicolon and double-quote
    # characters (the double-quote characters appearing as quoted-pair
    # construct).  Conversely, the display name for Who? could appear
    # without them because the question mark is legal in an atom.  Notice
    # also that jdoe@example.org and boss@nil.test have no display names
    # associated with them at all, and jdoe@example.org uses the simpler
    # address form without the angle brackets.
    it "should handle multiple recipients test email" do
      email =<<EMAILEND
From: "Joe Q. Public" <john.q.public@example.com>
To: Mary Smith <mary@x.test>, jdoe@example.org, Who? <one@y.test>
Cc: <boss@nil.test>, "Giant; \"Big\" Box" <sysservices@example.net>
Date: Tue, 1 Jul 2003 10:52:37 +0200
Message-ID: <5678.21-Nov-1997@example.com>

Hi everyone.
EMAILEND
      mail = Mail::Message.new(email)
      mail.from.formatted.should == ['"Joe Q. Public" <john.q.public@example.com>']
      mail.to.formatted.should == ['Mary Smith <mary@x.test>', 'jdoe@example.org', 'Who? <one@y.test>']
      mail.cc.formatted.should == ['boss@nil.test', '"Giant; \"Big\" Box" <sysservices@example.net>']
      mail.message_id.to_s.should == '<5678.21-Nov-1997@example.com>'
      mail.date.date_time.should == ::DateTime.parse('1 Jul 2003 10:52:37 +0200')
    end

    # From RFC 2822:
    # A.1.3. Group addresses
    # In this message, the "To:" field has a single group recipient named A
    # Group which contains 3 addresses, and a "Cc:" field with an empty
    # group recipient named Undisclosed recipients.
    it "should handle group address email test" do
      email =<<EMAILEND
From: Pete <pete@silly.example>
To: A Group:Chris Jones <c@a.test>,joe@where.test,John <jdoe@one.test>;
Cc: Undisclosed recipients:;
Date: Thu, 13 Feb 1969 23:32:54 -0330
Message-ID: <testabcd.1234@silly.example>

Testing.
EMAILEND
      mail = Mail::Message.new(email)
      mail.from.formatted.should == ['Pete <pete@silly.example>']
      mail.to.formatted.should == ['Chris Jones <c@a.test>', 'joe@where.test', 'John <jdoe@one.test>']
      mail.cc.group_names.should == ['Undisclosed recipients']
      mail.message_id.to_s.should == '<testabcd.1234@silly.example>'
      mail.date.date_time.should == ::DateTime.parse('Thu, 13 Feb 1969 23:32:54 -0330')
    end


    # From RFC 2822:
    # A.2. Reply messages
    # The following is a series of three messages that make up a
    # conversation thread between John and Mary.  John firsts sends a
    # message to Mary, Mary then replies to John's message, and then John
    # replies to Mary's reply message.
    # 
    # Note especially the "Message-ID:", "References:", and "In-Reply-To:"
    # fields in each message.
    it "should handle reply messages" do
      email =<<EMAILEND
From: John Doe <jdoe@machine.example>
To: Mary Smith <mary@example.net>
Subject: Saying Hello
Date: Fri, 21 Nov 1997 09:55:06 -0600
Message-ID: <1234@local.machine.example>

This is a message just to say hello.
So, "Hello".
EMAILEND
      mail = Mail::Message.new(email)
      mail.from.addresses.should == ['jdoe@machine.example']
      mail.to.addresses.should == ['mary@example.net']
      mail.subject.to_s.should == 'Saying Hello'
      mail.message_id.to_s.should == '<1234@local.machine.example>'
      mail.date.date_time.should == ::DateTime.parse('Fri, 21 Nov 1997 09:55:06 -0600')
    end

    # From RFC 2822:
    # When sending replies, the Subject field is often retained, though
    # prepended with "Re: " as described in section 3.6.5.
    # Note the "Reply-To:" field in the below message.  When John replies
    # to Mary's message above, the reply should go to the address in the
    # "Reply-To:" field instead of the address in the "From:" field.
    it "should handle reply message 2" do
      email =<<EMAILEND
From: Mary Smith <mary@example.net>
To: John Doe <jdoe@machine.example>
Reply-To: "Mary Smith: Personal Account" <smith@home.example>
Subject: Re: Saying Hello
Date: Fri, 21 Nov 1997 10:01:10 -0600
Message-ID: <3456@example.net>
In-Reply-To: <1234@local.machine.example>
References: <1234@local.machine.example>

This is a reply to your hello.
EMAILEND
      mail = Mail::Message.new(email)
      mail.from.addresses.should == ['mary@example.net']
      mail.to.addresses.should == ['jdoe@machine.example']
      mail.reply_to.addresses.should == ['smith@home.example']
      mail.subject.to_s.should == 'Re: Saying Hello'
      mail.message_id.to_s.should == '<3456@example.net>'
      mail.in_reply_to.message_ids.should == ['1234@local.machine.example']
      mail.references.message_ids.should == ['1234@local.machine.example']
      mail.date.date_time.should == ::DateTime.parse('Fri, 21 Nov 1997 10:01:10 -0600')
    end

    # From RFC 2822:
    # Final reply message
    it "should handle the final reply message" do
      email =<<EMAILEND
To: "Mary Smith: Personal Account" <smith@home.example>
From: John Doe <jdoe@machine.example>
Subject: Re: Saying Hello
Date: Fri, 21 Nov 1997 11:00:00 -0600
Message-ID: <abcd.1234@local.machine.tld>
In-Reply-To: <3456@example.net>
References: <1234@local.machine.example> <3456@example.net>

This is a reply to your reply.
EMAILEND
      mail = Mail::Message.new(email)
      mail.to.addresses.should == ['smith@home.example']
      mail.from.addresses.should == ['jdoe@machine.example']
      mail.subject.to_s.should == 'Re: Saying Hello'
      mail.date.date_time.should == ::DateTime.parse('Fri, 21 Nov 1997 11:00:00 -0600')
      mail.message_id.to_s.should == '<abcd.1234@local.machine.tld>'
      mail.in_reply_to.to_s.should == '<3456@example.net>'
      mail.references.message_ids.should == ['1234@local.machine.example', '3456@example.net']
    end

    # From RFC2822
    # A.3. Resent messages
    # Say that Mary, upon receiving this message, wishes to send a copy of
    # the message to Jane such that (a) the message would appear to have
    # come straight from John; (b) if Jane replies to the message, the
    # reply should go back to John; and (c) all of the original
    # information, like the date the message was originally sent to Mary,
    # the message identifier, and the original addressee, is preserved.  In
    # this case, resent fields are prepended to the message:
    #
    # If Jane, in turn, wished to resend this message to another person,
    # she would prepend her own set of resent header fields to the above
    # and send that.
    it "should handle the rfc resent example email" do
      email =<<EMAILEND
Resent-From: Mary Smith <mary@example.net>
Resent-To: Jane Brown <j-brown@other.example>
Resent-Date: Mon, 24 Nov 1997 14:22:01 -0800
Resent-Message-ID: <78910@example.net>
From: John Doe <jdoe@machine.example>
To: Mary Smith <mary@example.net>
Subject: Saying Hello
Date: Fri, 21 Nov 1997 09:55:06 -0600
Message-ID: <1234@local.machine.example>

This is a message just to say hello.
So, "Hello".
EMAILEND
      mail = Mail::Message.new(email)
      mail.resent_from.addresses.should == ['mary@example.net']
      mail.resent_to.addresses.should == ['j-brown@other.example']
      mail.resent_date.date_time.should == ::DateTime.parse('Mon, 24 Nov 1997 14:22:01 -0800')
      mail.resent_message_id.to_s.should == '<78910@example.net>'
      mail.from.addresses.should == ['jdoe@machine.example']
      mail.to.addresses.should == ['mary@example.net']
      mail.subject.to_s.should == 'Saying Hello'
      mail.date.date_time.should == ::DateTime.parse('Fri, 21 Nov 1997 09:55:06 -0600')
      mail.message_id.to_s.should == '<1234@local.machine.example>'
    end

    # A.4. Messages with trace fields
    # As messages are sent through the transport system as described in
    # [RFC2821], trace fields are prepended to the message.  The following
    # is an example of what those trace fields might look like.  Note that
    # there is some folding white space in the first one since these lines
    # can be long.
    it "should handle the RFC trace example email" do
      email =<<EMAILEND
Received: from x.y.test
   by example.net
   via TCP
   with ESMTP
   id ABC12345
   for <mary@example.net>;  21 Nov 1997 10:05:43 -0600
Received: from machine.example by x.y.test; 21 Nov 1997 10:01:22 -0600
From: John Doe <jdoe@machine.example>
To: Mary Smith <mary@example.net>
Subject: Saying Hello
Date: Fri, 21 Nov 1997 09:55:06 -0600
Message-ID: <1234@local.machine.example>

This is a message just to say hello.
So, "Hello".
EMAILEND
      mail = Mail::Message.new(email)
      mail.received[0].info.should == 'from x.y.test by example.net via TCP with ESMTP id ABC12345 for <mary@example.net>'
      mail.received[0].date_time.should == ::DateTime.parse('21 Nov 1997 10:05:43 -0600')
      mail.received[1].info.should == 'from machine.example by x.y.test'
      mail.received[1].date_time.should == ::DateTime.parse('21 Nov 1997 10:01:22 -0600')
      mail.from.addresses.should == ['jdoe@machine.example']
      mail.to.addresses.should == ['mary@example.net']
      mail.subject.to_s.should == 'Saying Hello'
      mail.date.date_time.should == ::DateTime.parse('Fri, 21 Nov 1997 09:55:06 -0600')
      mail.message_id.to_s.should == '<1234@local.machine.example>'
    end

    # A.5. White space, comments, and other oddities
    # White space, including folding white space, and comments can be
    # inserted between many of the tokens of fields.  Taking the example
    # from A.1.3, white space and comments can be inserted into all of the
    # fields.
    #
    # The below example is aesthetically displeasing, but perfectly legal.
    # Note particularly (1) the comments in the "From:" field (including
    # one that has a ")" character appearing as part of a quoted-pair); (2)
    # the white space absent after the ":" in the "To:" field as well as
    # the comment and folding white space after the group name, the special
    # character (".") in the comment in Chris Jones's address, and the
    # folding white space before and after "joe@example.org,"; (3) the
    # multiple and nested comments in the "Cc:" field as well as the
    # comment immediately following the ":" after "Cc"; (4) the folding
    # white space (but no comments except at the end) and the missing
    # seconds in the time of the date field; and (5) the white space before
    # (but not within) the identifier in the "Message-ID:" field.
    it "should handle the rfc whitespace test email" do
      email =<<EMAILEND
From: Pete(A wonderful \\) chap) <pete(his account)@silly.test(his host)>
To:A Group(Some people)
     :Chris Jones <c@(Chris's host.)public.example>,
         joe@example.org,
  John <jdoe@one.test> (my dear friend); (the end of the group)
Cc:(Empty list)(start)Undisclosed recipients  :(nobody(that I know))  ;
Date: Thu,
      13
        Feb
          1969
      23:32
               -0330 (Newfoundland Time)
Message-ID:              <testabcd.1234@silly.test>

Testing.
EMAILEND
      mail = Mail::Message.new(email)
      mail.from.addresses.should == ['pete(his account)@silly.test']
      mail.to.addresses.should == ["c@(Chris's host.)public.example", 'joe@example.org', 'jdoe@one.test']
      mail.cc.group_names.should == ['(Empty list)(start)Undisclosed recipients ']
      mail.date.date_time.should == ::DateTime.parse('Thu, 13 Feb 1969 23:32 -0330')
      mail.message_id.to_s.should == '<testabcd.1234@silly.test>'
    end

    # A.6. Obsoleted forms
    # The following are examples of obsolete (that is, the "MUST NOT
    # generate") syntactic elements described in section 4 of this
    # document.
    # A.6.1. Obsolete addressing
    # Note in the below example the lack of quotes around Joe Q. Public,
    # the route that appears in the address for Mary Smith, the two commas
    # that appear in the "To:" field, and the spaces that appear around the
    # "." in the jdoe address.
    it "should handle the rfc obsolete addressing" do
      pending
      email =<<EMAILEND
From: Joe Q. Public <john.q.public@example.com>
To: Mary Smith <@machine.tld:mary@example.net>, , jdoe@test   . example
Date: Tue, 1 Jul 2003 10:52:37 +0200
Message-ID: <5678.21-Nov-1997@example.com>

Hi everyone.
EMAILEND
      mail = Mail::Message.new(email)
      mail.from.addresses.should == ['john.q.public@example.com']
      mail.from.formatted.should == ['"Joe Q. Public" <john.q.public@example.com>']
      mail.to.addresses.should == ["@machine.tld:mary@example.net", 'jdoe@test.example']
      mail.date.date_time.should == ::DateTime.parse('Tue, 1 Jul 2003 10:52:37 +0200')
      mail.message_id.to_s.should == '<5678.21-Nov-1997@example.com>'
    end

    # A.6.2. Obsolete dates
    # 
    # The following message uses an obsolete date format, including a non-
    # numeric time zone and a two digit year.  Note that although the
    # day-of-week is missing, that is not specific to the obsolete syntax;
    # it is optional in the current syntax as well.
    it "should handle the rfc obsolete dates" do
      email =<<EMAILEND
From: John Doe <jdoe@machine.example>
To: Mary Smith <mary@example.net>
Subject: Saying Hello
Date: 21 Nov 97 09:55:06 GMT
Message-ID: <1234@local.machine.example>

This is a message just to say hello.
So, "Hello".
EMAILEND
      doing { Mail::Message.new(email) }.should_not raise_error
    end

    # A.6.3. Obsolete white space and comments
    # 
    # White space and comments can appear between many more elements than
    # in the current syntax.  Also, folding lines that are made up entirely
    # of white space are legal.
    # 
    # Note especially the second line of the "To:" field.  It starts with
    # two space characters.  (Note that "__" represent blank spaces.)
    # Therefore, it is considered part of the folding as described in
    # section 4.2.  Also, the comments and white space throughout
    # addresses, dates, and message identifiers are all part of the
    # obsolete syntax.
    it "should handle the rfc obsolete whitespace email" do
      email =<<EMAILEND
From  : John Doe <jdoe@machine(comment).  example>
To    : Mary Smith
__
          <mary@example.net>
Subject     : Saying Hello
Date  : Fri, 21 Nov 1997 09(comment):   55  :  06 -0600
Message-ID  : <1234   @   local(blah)  .machine .example>

This is a message just to say hello.
So, "Hello".
EMAILEND
      doing { Mail::Message.new(email) }.should_not raise_error
    end

  end

  describe "from the wild" do
    it "should return an 'encoded' version without raising a SystemStackError" do
      message = Mail::Message.new(File.read(fixture('emails/raw_email_encoded_stack_level_too_deep')))
      doing { message.encoded }.should_not raise_error
    end
  end
  
end