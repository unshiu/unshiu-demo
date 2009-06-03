
class MsgManagerSendWorker < BackgrounDRb::MetaWorker
  include MsgManagerSendWorkerModule
end
