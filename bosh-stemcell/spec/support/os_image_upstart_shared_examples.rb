shared_examples_for 'an upstart-based OS image' do
  context 'installed by rsyslog_config' do
    RSYSLOG_EXECUTABLE = '/usr/sbin/rsyslogd'

    describe file('/etc/init/rsyslog.conf') do
      its(:content) { should match RSYSLOG_EXECUTABLE }
    end

    # verify that the path used in the upstart config points to an actual executable
    describe file(RSYSLOG_EXECUTABLE) do
      it { should be_file }
      it { should be_executable }
    end

    # Make sure that rsyslog starts with the machine
    describe file('/etc/init.d/rsyslog') do
      it { should be_linked_to('/lib/init/upstart-job') }
      it { should be_executable }
    end

    describe service('rsyslog') do
      it { should be_enabled_for_level(2) }
      it { should be_enabled_for_level(3) }
      it { should be_enabled_for_level(4) }
      it { should be_enabled_for_level(5) }
    end
  end

  context 'X Windows must not be enabled unless required (stig: V-38674)' do
    describe package('xserver-xorg') do
      it { should_not be_installed }
    end
  end
end
