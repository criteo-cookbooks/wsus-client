require_relative 'job'

module WsusClient
  # Manage Update download job
  class DownloadJob < Job
    def initialize(session)
      super session.CreateUpdateDownloader
    end

    protected

    def start_job(worker)
      # Trick: pass the worker object as callback parameter
      # I didn't find any way to get the callback working
      worker.BeginDownload worker, worker, nil
    end

    def complete_job(job)
      worker.EndDownload job
    end
  end
end
