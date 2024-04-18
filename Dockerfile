FROM ros:humble

RUN apt-get update && apt-get -y install pip
RUN sudo -H pip install --upgrade pip
RUN sudo -H pip install setuptools==58.2.0 #fix of humble error
RUN sudo -H pip install PySimpleGUI

RUN sudo apt install python3-rosdep python3-pip python3-colcon-common-extensions iputils-ping tmux tmuxinator -y
RUN mkdir -p $HOME/ros2/aerostack2_ws/src/
WORKDIR $HOME/ros2/aerostack2_ws/src/

RUN git clone https://github.com/aerostack2/aerostack2.git
WORKDIR $HOME/ros2/aerostack2_ws
RUN bash -c ". /opt/ros/humble/setup.bash && rosdep update"
RUN bash -c ". /opt/ros/humble/setup.bash && rosdep install -y -r -q --from-paths src --ignore-src --rosdistro humble"
RUN bash -c ". /opt/ros/humble/setup.bash && colcon build --symlink-install --parallel-workers 32"

ENV AEROSTACK2_PATH=$HOME/ros2/aerostack2_ws/src/aerostack2
RUN echo "export AEROSTACK2_PATH=$AEROSTACK2_PATH" >> $HOME/.bashrc
RUN echo "source $AEROSTACK2_PATH/as2_cli/setup_env.bash" >> $HOME/.bashrc

COPY project_gazebo /project_gazebo
WORKDIR /project_gazebo

COPY libmodality_ros_hook_22.04_amd64.so /

CMD bash -c "MODALITY_ROS_IGNORED_TOPICS='/parameter_events,/clock' LD_PRELOAD=/libmodality_ros_hook_22.04_amd64.so:/opt/ros/humble/lib/librmw_fastrtps_cpp.so ./launch_as2.bash -m"