package cmd

import (
	"bufio"
	"os"
	"strconv"
	"strings"
	"sync"

	"github.com/hahwul/dalfox/pkg/printing"
	"github.com/hahwul/dalfox/pkg/scanning"
	"github.com/spf13/cobra"
)

// pipeCmd represents the pipe command
var pipeCmd = &cobra.Command{
	Use:   "pipe [flags]",
	Short: "Use pipeline mode",
	Run: func(cmd *cobra.Command, args []string) {
		var targets []string
		sc := bufio.NewScanner(os.Stdin)
		printing.DalLog("SYSTEM", "Using pipeline mode", options)
		for sc.Scan() {
			target := strings.ToLower(sc.Text())
			targets = append(targets, target)
		}
		targets = unique(targets)
		printing.DalLog("SYSTEM", "Loaded "+strconv.Itoa(len(targets))+" target urls", options)

		multi, _ := cmd.Flags().GetBool("multicast")
		if multi {
			printing.DalLog("SYSTEM", "Using multicasting mode", options)
			t := scanning.MakeTargetSlice(targets)
			var wg sync.WaitGroup
			for k, v := range t {
				wg.Add(1)
				go func(k string, v []string) {
					defer wg.Done()
					printing.DalLog("SYSTEM", "testing to '"+k+"' => "+strconv.Itoa(len(v))+" urls", options)
					for i := range v {
						scanning.Scan(v[i], options, strconv.Itoa(len(v)))
					}
				}(k, v)
			}
			wg.Wait()
		} else {
			options.AllURLS = len(targets)
			for i := range targets {
				options.NowURL = i + 1
				scanning.Scan(targets[i], options, strconv.Itoa(i))
			}

		}

	},
}

func init() {
	rootCmd.AddCommand(pipeCmd)
	pipeCmd.Flags().Bool("multicast", false, "Scanning N*Host mode")

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// pipeCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// pipeCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}
