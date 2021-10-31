require "pyroscope"

class ApplicationJob < ActiveJob::Base
  around_perform :add_pyroscope

  private

  def add_pyroscope
    tags = {
      "job_class": self.class.name,
      "job_id": job_id
    }

    Pyroscope.tag_wrapper(tags) do
      yield
    end
  end
end
