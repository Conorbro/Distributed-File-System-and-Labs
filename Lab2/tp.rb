require 'thread'
work_q = Queue.new # represents queue of work that has to be done
(0..50).to_a.each{|x| work_q.push x } # Push numbers 0 to 50 onto the work_q
workers = (0...4).map do
  Thread.new do
    begin
      while x = work_q.pop(true)
        50.times{print "TEST-"}
      end
    rescue ThreadError
    end
  end
end; "ok"
workers.map(&:join); "ok"
