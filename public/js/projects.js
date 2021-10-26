/**
 * Create custom HTML tag. Usage in HTML:
 *    <x-project name="<required> name of project"
 *    description="<optional> description of project"
 *    homepage="<optional> link to home page of project"
 *    source="<optional> link to source of project"></x-project>
 */
class ProjectElement extends HTMLElement {
    constructor() {
        super();

        const name = this.getAttribute("name");
        const description = this.getAttribute("description");
        const homepage = this.getAttribute("homepage");
        const source = this.getAttribute("source");

        const wrapper = createElement("div", {
            clazz: "project"
        });

        const nameElement = createElement("h3", {
            clazz: "name",
            text: name
        });
        const descriptionElement = createElement("p", {
            clazz: "description",
            text: description
        });
        const homepageLinkElement = createElement("a", {
            text: "homepage"
        });
        const sourceLinkElement = createElement("a", {
            text: "source"
        });
        const linksElement = createElement("p", {
            clazz: "links"
        });

        homepageLinkElement.href = homepage;
        homepageLinkElement.target = "_blank";
        sourceLinkElement.href = source;
        sourceLinkElement.target = "_blank";

        this.appendChild(wrapper);
        wrapper.appendChild(nameElement);
        if (description) {
            wrapper.appendChild(descriptionElement);
        }
        if (homepage || source) {
            wrapper.appendChild(linksElement);
            linksElement.appendChild(createElement("span", {text: "Link(s): "}));

            if (homepage) {
                linksElement.appendChild(homepageLinkElement);
            }
            if (homepage && source) {
                linksElement.appendChild(createElement("span", {text: " - "}));
            }
            if (source) {
                linksElement.appendChild(sourceLinkElement);
            }
        }
    }
}

const createElement = (name, {clazz, text}) => {
    const element = document.createElement(name);
    if (clazz) {
        element.setAttribute("class", clazz);
    }
    if (text) {
        element.textContent = text;
    }
    return element;
}

const initProjects = () => {
    customElements.define("x-project", ProjectElement);
}

// Run on init
initProjects();
