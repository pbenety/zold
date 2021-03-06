# Copyright (c) 2018 Yegor Bugayenko
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

require 'slop'
require_relative '../log'
require_relative '../score'

# SCORE command.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2018 Yegor Bugayenko
# License:: MIT
module Zold
  # Calculate score
  class Calculate
    def initialize(log: Log::Quiet.new)
      @log = log
    end

    def run(args = [])
      opts = Slop.parse(args, help: true, suppress_errors: true) do |o|
        o.banner = "Usage: zold score [options]
Available options:"
        o.string '--time',
          'The time to start a score prefix with (default: current time)',
          default: Time.now.utc.iso8601
        o.string '--invoice',
          'The invoice you want to collect money to'
        o.integer '--port',
          "TCP port to open for the Net (default: #{Remotes::PORT})",
          default: Remotes::PORT
        o.string '--host', 'Host name (default: 127.0.0.1)',
          default: '127.0.0.1'
        o.integer '--strength',
          "The strength of the score (default: #{Score::STRENGTH})",
          default: Score::STRENGTH
        o.integer '--max',
          'Maximum value to find and then stop (default: 8)',
          default: 8
        o.bool '--hide-hash', 'Don\'t print hash',
          default: false
        o.bool '--hide-time', 'Don\'t print calculation time per each score',
          default: false
        o.bool '--help', 'Print instructions'
      end
      if opts.help?
        @log.info(opts.to_s)
        return
      end
      calculate(opts)
    end

    private

    def calculate(opts)
      start = Time.now
      mstart = Time.now
      strength = opts[:strength]
      raise "Invalid strength: #{strength}" if strength <= 0 || strength > 8
      score = Zold::Score.new(
        Time.parse(opts[:time]), opts[:host], opts[:port].to_i,
        opts[:invoice], strength: strength
      )
      loop do
        msg = score.to_s
        msg += (score.value > 0 ? ' ' + score.hash : '') unless opts['hide-hash']
        msg += " #{(Time.now - mstart).round(2)}s" unless opts['hide-time']
        @log.info(msg)
        break if score.value >= opts[:max].to_i
        mstart = Time.now
        score = score.next
      end
      seconds = (Time.now - start).round(2)
      @log.info("Took #{seconds} seconds, #{seconds / score.value} per value")
      score
    end
  end
end
