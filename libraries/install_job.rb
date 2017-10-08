require_relative 'job.rb'

module WsusClient
  class InstallJob < Job
    def initialize(session)
      worker = session.CreateUpdateInstaller
      worker.ForceQuiet = true
      super worker
    end

    protected

    def start_job(worker)
      # Trick: pass the worker object as callback parameter
      # I didn't find any way to get the callback working
      worker.BeginInstall worker, worker, nil
    end

    def complete_job(job)
      worker.EndInstall job
    end
  end
end
