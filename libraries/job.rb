module WsusClient
  # Base class for WUA jobs based on asynchronous API
  # See http://msdn.microsoft.com/aa387099 for the API documentation
  # This class is "abstract" and can't be instanciated directly.
  # You have to inherit and implement the following protected methods:
  #    start_job
  #    complete_job
  class Job
    # ResultCode values: http://msdn.microsoft.com/aa387095
    module ResultCode
      NOT_STARTED = 0 unless constants.include? :NOT_STARTED
      IN_PROGRESS = 1 unless constants.include? :IN_PROGRESS
      SUCCEEDED = 2 unless constants.include? :SUCCEEDED
      SUCCEEDED_WITH_ERRORS = 3 unless constants.include? :SUCCEEDED_WITH_ERRORS
      FAILED = 4 unless constants.include? :FAILED
      ABORTED = 5 unless constants.include? :ABORTED
    end

    attr_reader :worker

    def initialize(worker)
      raise TypeError, 'WsusClient::Job is an "abstract" class and must not be instanciated directly.' if self.class == ::WsusClient::Job
      @worker = worker
    end

    def run(updates, timeout = 3600, &block)
      require 'win32ole' if RUBY_PLATFORM =~ /mswin|mingw32|windows/
      require 'timeout'

      # Prepare update collection and status
      worker.Updates = ::WIN32OLE.new('Microsoft.Update.UpdateColl')
      updates.each { |update| worker.Updates.Add update }
      updates_status = updates.map { |u| [u, ResultCode::NOT_STARTED] }.to_h

      # Start the asynchronous job
      job = start_job(worker)

      # Wait for completion & notify progress
      ::Timeout.timeout(timeout) do
        while progress?(job, updates_status, &block)
          break if job.IsCompleted
          ::Kernel.sleep 1
        end
      end

      # Complete the asynchronous job
      job.CleanUp
      complete_job(job)
    rescue ::Timeout::Error
      job.RequestAbort unless job.IsCompleted
      raise ::Timeout::Error, "The operation did not complete within the allotted timeout of #{timeout} seconds!"
    end

    private

    def progress?(job, updates_status)
      progress = job.GetProgress
      completion = progress.PercentComplete
      updates_status.each_with_index do |(update, status), index|
        next if status == ResultCode::SUCCEEDED
        case updates_status[update] = progress.GetUpdateResult(index).ResultCode
        when ResultCode::SUCCEEDED
          yield update, completion if block_given?
        when ResultCode::SUCCEEDED_WITH_ERRORS, ResultCode::FAILED, ResultCode::ABORTED
          return false
        end
      end
      true
    end

    protected

    def start_job(_worker)
      raise NotImplementedError
    end

    def complete_job(_job)
      raise NotImplementedError
    end
  end
end
