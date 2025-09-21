from scripts import suricata_generate


def test_render_substitutes_ruleset():
    template = "ruleset: {{ ruleset | default('balanced') }}"
    rendered = suricata_generate.render(template, "max-performance")
    assert rendered == "ruleset: max-performance"
