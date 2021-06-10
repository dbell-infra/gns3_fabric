import yaml
import sys
from jinja2 import Template

def build_template(template, output_file):
    with open(template) as file:
        template_config = yaml.safe_load(file)


    with open(f"roles/fabric/python/{template_config['target_template']}") as file:
        j2_template = file.read()

    with open(output_file, 'w') as file:
        file.write(Template(j2_template).render(**template_config))




if __name__ == "__main__":
    build_template(sys.argv[1], sys.argv[2])