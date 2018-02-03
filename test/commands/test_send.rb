# Copyright (c) 2018 Zerocracy, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'minitest/autorun'
require 'tmpdir'
require_relative '../../lib/zold/wallet.rb'
require_relative '../../lib/zold/key.rb'
require_relative '../../lib/zold/commands/send.rb'

# SEND test.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2018 Zerocracy, Inc.
# License:: MIT
class TestSend < Minitest::Test
  def test_sends_from_wallet_to_wallet
    Dir.mktmpdir 'test' do |dir|
      source = Zold::Wallet.new(File.join(dir, 'source.xml'))
      source.init(1, Zold::Key.new('fixtures/id_rsa.pub'))
      target = Zold::Wallet.new(File.join(dir, 'target.xml'))
      target.init(2, Zold::Key.new('fixtures/id_rsa.pub'))
      amount = Zold::Amount.new(zld: 14.95)
      Zold::Send.new(
        payer: source,
        receiver: target,
        amount: amount,
        pvtkey: Zold::Key.new('fixtures/id_rsa')
      ).run
      assert source.balance == amount.mul(-1)
      assert target.balance == amount
    end
  end
end
