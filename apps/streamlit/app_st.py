import streamlit as st


def workflow_onboard():
    st.subheader("Onboard")
    pass


def workflow_train():
    st.subheader("Train")
    pass


def workflow_playground():
    st.subheader("Playground")
    pass


def app():
    st.sidebar.title("Momentos: Capture and Replay Your History")
    task = st.sidebar.radio("Select a task", ("Onboard", "Train", "Playground"))
    if task == "Onboard":
        workflow_onboard()
    elif task == "Train":
        workflow_train()
    elif task == "Playground":
        workflow_playground()


if __name__ == "__main__":
    app()
