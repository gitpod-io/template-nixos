{ ... }:

{
  name = "integration-tests";

  # For faster dev cycles it's also possible to disable the code-linters (this shouldn't be commited though)
  # skipLint = true;

  enableOCR = true;

  machine = ./configuration.nix;

  testScript = ''
    start_all()

    machine.wait_for_unit("multi-user.target")
    machine.wait_until_succeeds("pgrep -f 'agetty.*tty1'")
    machine.screenshot("postboot")

    with subtest("nixos user exists"):
        machine.succeed("getent passwd nixos")
        machine.screenshot("assert_user_exists")


    with subtest("login tty is visible:"):
        machine.wait_for_text("login:")

    with subtest("nixos can login via ssh"):
        machine.wait_for_unit("sshd")

        machine.succeed(
            "sshpass -p password nixos  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no nixos@localhost 'echo hello world' >&2"
        )

    with subtest("git is installed"):
        machine.succeed("git --help")
  '';
}
