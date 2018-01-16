require 'disque'

class Disque::Client < Disque

  # https://github.com/antirez/disque#info
  def info
    call 'INFO'
  end

  # https://github.com/antirez/disque#show-job-id
  def show(job_id)
    job = call 'SHOW', job_id
    job.is_a?(Array) ? Hash[*job] : job
  end

  # https://github.com/antirez/disque#ackjob-jobid1-jobid2--jobidn
  def ackjob(*job_ids)
    call 'ACKJOB', *job_ids
  end

  # https://github.com/antirez/disque#deljob-job-id--job-id
  def deljob(*job_ids)
    call 'DELJOB', *job_ids
  end

  # https://github.com/antirez/disque#qstat-queue-name
  def qstat(queue)
    stat = call 'QSTAT', queue
    Hash[*stat]
  end

  # https://github.com/antirez/disque#qscan-count-count-busyloop-minlen-len-maxlen-len-importrate-rate
  def qscan(count: 0, busyloop: false, minlen: 0, maxlen: 0, importrate: 0)
    scan do |cursor|
      args = ['QSCAN']
      args << 'COUNT'      << count      if count && count > 0
      args << 'BUSYLOOP'                 if busyloop
      args << 'MINLEN'     << minlen     if minlen && minlen > 0
      args << 'MAXLEN'     << maxlen     if maxlen && maxlen > 0
      args << 'IMPORTRATE' << importrate if importrate && importrate > 0
      args
    end
  end

  # https://github.com/antirez/disque#jscan-cursor-count-count-busyloop-queue-queue-state-state1-state-state2--state-staten-reply-allid
  def jscan(count: 0, busyloop: false, queue: nil, state: nil, reply: 'all')
    scan do |cursor|
      args = ['JSCAN', cursor]
      args << 'COUNT'    << count if count && count > 0
      args << 'BUSYLOOP'          if busyloop
      args << 'QUEUE'    << queue if queue

      Array(state).each do |s|
        args << 'STATE' << s
      end if state

      args << 'REPLY' << reply if reply
      args
    end.lazy.map do |item|
      item.is_a?(Array) ? Hash[*item] : item
    end
  end

  private

    def scan(&make_args)
      Enumerator.new do |y|
        cursor = '0'
        loop do
          args = make_args.call(cursor)
          cursor, items = call *args
          items.each do |item|
            y << item
          end
          break if cursor == '0' || items.length == 0
        end
      end
    end

end
