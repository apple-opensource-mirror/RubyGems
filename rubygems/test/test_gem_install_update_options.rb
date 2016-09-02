require File.expand_path('../gem_installer_test_case', __FILE__)
require 'rubygems/install_update_options'
require 'rubygems/command'

class TestGemInstallUpdateOptions < GemInstallerTestCase

  def setup
    super

    @cmd = Gem::Command.new 'dummy', 'dummy'
    @cmd.extend Gem::InstallUpdateOptions
    @cmd.add_install_update_options
  end

  def test_add_install_update_options
    args = %w[-i /install_to --rdoc --ri -E -f -t -w -P HighSecurity
              --ignore-dependencies --format-exec --include-dependencies]

    assert @cmd.handles?(args)
  end

  def test_security_policy
    @cmd.handle_options %w[-P HighSecurity]

    assert_equal Gem::Security::HighSecurity, @cmd.options[:security_policy]
  end

  def test_security_policy_unknown
    @cmd.add_install_update_options

    assert_raises OptionParser::InvalidArgument do
      @cmd.handle_options %w[-P UnknownSecurity]
    end
  end

  def test_user_install_enabled
    @cmd.handle_options %w[--user-install]

    assert @cmd.options[:user_install]

    @installer = Gem::Installer.new @gem, @cmd.options
    @installer.install
    assert File.exist?(File.join(Gem.user_dir, 'gems'))
    assert File.exist?(File.join(Gem.user_dir, 'gems',
                                 @spec.full_name))
  end

  def test_user_install_disabled_read_only
    if win_platform?
      skip('test_user_install_disabled_read_only test skipped on MS Windows')
    else
      @cmd.handle_options %w[--no-user-install]

      refute @cmd.options[:user_install]

      File.chmod 0755, @userhome
      FileUtils.chmod 0000, @gemhome

      assert_raises(Gem::FilePermissionError) do
        @installer = Gem::Installer.new @gem, @cmd.options
      end
    end
  ensure
    FileUtils.chmod 0755, @gemhome
  end

end

