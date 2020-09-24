module Error::Helpers
  class Render
    def self.json(_error, _status, _message)
      {
        "errors": [
                    {
                      "status": _status,
                      "title":  _error,
                      "detail": _message
                    }
                  ]
      }.as_json
    end
  end
end